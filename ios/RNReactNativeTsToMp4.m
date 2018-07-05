//
//  RNReactNativeTsToMp4.m
//  Hive
//
//  Created by Kamil Badyla on 17/05/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RNReactNativeTsToMp4.h"
#import <FFmpeg/avformat.h>

@implementation RNReactNativeTsToMp4

RCT_EXPORT_MODULE();

- (instancetype)init {
    self = [super init];
    if (self) {
        av_register_all();
    }
    return self;
}

RCT_EXPORT_METHOD(convert:(NSArray<NSString*>*)inputFilePaths toMP4:(NSString*)outputFilePath options:(NSDictionary*)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    int errorCode;
    
    // Opening output file and configure the output context
    const char *outputFilename = [outputFilePath UTF8String];
    
    AVFormatContext *outputFormatContext = NULL;
    
    avformat_alloc_output_context2(&outputFormatContext, NULL, NULL, outputFilename);
    if (!outputFormatContext) {
        errorCode = AVERROR_UNKNOWN;
        [self closeInput:NULL
                  output:outputFormatContext
            outputFormat:NULL
           streamMapping:NULL
               errorCode:errorCode
            errorMessage:@"Can't alloc output context"
                resolver:resolve
                rejecter:reject];
        return;
    }
    
    AVOutputFormat *outputFormat = outputFormatContext->oformat;
    
    // Configuring input format
    int *streamMapping = NULL;
    int streamMappingSize = 0;
    int streamIndex = 0;
    
    // Arrays to store last PTS and DTS values for output streams' packets
    int64_t *last_streams_pts = NULL;
    int64_t *last_streams_dts = NULL;
    
    // Opening input for each file
    for (int fileIndex = 0; fileIndex < inputFilePaths.count; fileIndex++) {
        NSString *inputFilePath = inputFilePaths[fileIndex];
        
        // Preparing variables for input
        AVFormatContext *inputFormatContext = NULL;
        AVDictionary *inputOptions = NULL;
        const char *inputFilename = [inputFilePath UTF8String];
        
        // Creating input context
        if ((errorCode = avformat_open_input(&inputFormatContext, inputFilename, NULL, &inputOptions)) < 0) {
            return [self closeInput:inputFormatContext
                             output:outputFormatContext
                       outputFormat:outputFormat
                      streamMapping:streamMapping
                          errorCode:errorCode
                           errorMessage:[NSString stringWithFormat:@"could not open input file '%s'", inputFilename]
                           resolver:resolve
                           rejecter:reject];
            return;
        }
        
        // Getting streams from input context
        if ((errorCode = avformat_find_stream_info(inputFormatContext, 0)) < 0) {
            if (fileIndex > 0)
                av_write_trailer(outputFormatContext);
            
            [self closeInput:inputFormatContext
                      output:outputFormatContext
                outputFormat:outputFormat
               streamMapping:streamMapping
                   errorCode:errorCode
                errorMessage:@"Failed to retrieve input stream information"
                    resolver:resolve
                    rejecter:reject];
            return;
        }
        
        // Extracting file info to input context
        av_dump_format(inputFormatContext, 0, inputFilename, 0);
        
        // Creating mapping between input and output streams
        if (streamMapping == NULL) {
            // Creating arrays for streams and last DTS and PTS values
            streamMappingSize = inputFormatContext->nb_streams;
            last_streams_pts = av_mallocz_array(streamMappingSize,  sizeof(*last_streams_pts));
            last_streams_dts = av_mallocz_array(streamMappingSize,  sizeof(*last_streams_dts));
            streamMapping = av_mallocz_array(streamMappingSize, sizeof(*streamMapping));
            if (!streamMapping) {
                errorCode = AVERROR(ENOMEM);
                [self closeInput:inputFormatContext
                          output:outputFormatContext
                    outputFormat:outputFormat
                   streamMapping:streamMapping
                       errorCode:errorCode
                    errorMessage:nil
                        resolver:resolve
                        rejecter:reject];
                return;
            }
            
            // Iterating over input streams and creating corresponding output streams
            for (int i = 0; i < inputFormatContext->nb_streams; i++) {
                AVStream *in_stream = inputFormatContext->streams[i];
                AVCodecParameters *in_codecpar = in_stream->codecpar;
                
                // Checking input file's streams. We transfer only Video, Audio and Subtitles
                if (in_codecpar->codec_type != AVMEDIA_TYPE_AUDIO &&
                    in_codecpar->codec_type != AVMEDIA_TYPE_VIDEO &&
                    in_codecpar->codec_type != AVMEDIA_TYPE_SUBTITLE) {
                    streamMapping[i] = -1;
                    continue;
                }
                
                last_streams_pts[i] = 0;
                last_streams_dts[i] = 0;
                streamMapping[i] = streamIndex++;
                
                // Creating output stream
                AVStream *out_stream = avformat_new_stream(outputFormatContext, NULL);
                if (!out_stream) {
                    errorCode = AVERROR_UNKNOWN;
                    return [self closeInput:inputFormatContext
                                     output:outputFormatContext
                               outputFormat:outputFormat
                              streamMapping:streamMapping
                                  errorCode:errorCode
                               errorMessage:@"Failed allocating output stream"
                                   resolver:resolve
                                   rejecter:reject];
                    return;
                }
                
                // Copying codec parameters from input to output context
                errorCode = avcodec_parameters_copy(out_stream->codecpar, in_codecpar);
                if (errorCode < 0) {
                    [self closeInput:inputFormatContext
                              output:outputFormatContext
                        outputFormat:outputFormat
                       streamMapping:streamMapping
                           errorCode:errorCode
                        errorMessage:@"Failed to copy codec parameters"
                            resolver:resolve
                            rejecter:reject];
                    return;
                }
                out_stream->codecpar->codec_tag = 0;
            }
        }
        
        // Writing header to output file
        if (fileIndex == 0) {
            av_dump_format(outputFormatContext, 0, outputFilename, 1);
            
            if (!(outputFormat->flags & AVFMT_NOFILE)) {
                errorCode = avio_open(&outputFormatContext->pb, outputFilename, AVIO_FLAG_WRITE);
                if (errorCode < 0) {
                    [self closeInput:inputFormatContext
                              output:outputFormatContext
                        outputFormat:outputFormat
                       streamMapping:streamMapping
                           errorCode:errorCode
                        errorMessage:[NSString stringWithFormat:@"RHCRecordingRemuxer could not open output file '%s'", outputFilename]
                            resolver:resolve
                            rejecter:reject];
                    return;
                }
            }
            
            errorCode = avformat_write_header(outputFormatContext, NULL);
            if (errorCode < 0) {
                [self closeInput:inputFormatContext
                          output:outputFormatContext
                    outputFormat:outputFormat
                   streamMapping:streamMapping
                       errorCode:errorCode
                    errorMessage:@"error occurred when opening output file"
                        resolver:resolve
                        rejecter:reject];
                return;
            }
        }
        
        // Writing packets to output file
        AVPacket packet;
        while (1) {
            AVStream *in_stream, *out_stream;
            
            errorCode = av_read_frame(inputFormatContext, &packet);
            if (errorCode < 0)
                break;
            
            int in_stream_index = packet.stream_index;
            in_stream  = inputFormatContext->streams[packet.stream_index];
            if (packet.stream_index >= streamMappingSize ||
                streamMapping[packet.stream_index] < 0) {
                av_packet_unref(&packet);
                continue;
            }
            
            packet.stream_index = streamMapping[packet.stream_index];
            out_stream = outputFormatContext->streams[packet.stream_index];
            
            /* copy packet */
            int64_t duration = av_rescale_q(packet.duration, in_stream->time_base, out_stream->time_base);
            
            int64_t last_pts = last_streams_pts[in_stream_index];
            int64_t last_dts = last_streams_pts[in_stream_index];
            
            int64_t new_pts = last_pts + duration;
            int64_t new_dts = last_dts + duration;
            
            packet.duration = duration;
            packet.pts = new_pts;
            packet.dts = new_dts;
            packet.pos = -1;
            
            errorCode = av_interleaved_write_frame(outputFormatContext, &packet);
            if (errorCode < 0) {
                break;
            }
            last_streams_pts[in_stream_index] = new_pts;
            last_streams_dts[in_stream_index] = new_dts;
            
            av_packet_unref(&packet);
        }
        avformat_close_input(&inputFormatContext);
    }
    
    av_write_trailer(outputFormatContext);
    [self closeInput:NULL
              output:outputFormatContext
        outputFormat:outputFormat
       streamMapping:streamMapping
           errorCode:0
        errorMessage:nil
            resolver:resolve
            rejecter:reject];
}

-(void)closeInput:(AVFormatContext *)inputFormatContext
           output:(AVFormatContext *)outputFormatContext
     outputFormat:(AVOutputFormat*)outputFormat
    streamMapping:(int*)streamMapping
        errorCode:(int)errorCode
     errorMessage:(NSString*)errorMessage
         resolver:(RCTPromiseResolveBlock)resolve
         rejecter:(RCTPromiseRejectBlock)reject
{
    
    avformat_close_input(&inputFormatContext);
    
    /* close output */
    BOOL outputContextPresent = outputFormatContext && !(outputFormat->flags & AVFMT_NOFILE);
    if (outputContextPresent)
        avio_closep(&outputFormatContext->pb);
    
    avformat_free_context(outputFormatContext);
    
    av_freep(&streamMapping);
    
    if (errorCode < 0 && errorCode != AVERROR_EOF) {
        reject([NSString stringWithFormat:@"%d", errorCode], errorMessage ? errorMessage : [NSString stringWithUTF8String:av_err2str(errorCode)], nil);
    }
    
    resolve(nil);
}

@end
