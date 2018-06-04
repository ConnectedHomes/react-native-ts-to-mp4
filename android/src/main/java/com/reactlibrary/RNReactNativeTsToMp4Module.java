
package com.reactlibrary;

import com.github.hiteshsondhi88.libffmpeg.ExecuteBinaryResponseHandler;
import com.github.hiteshsondhi88.libffmpeg.FFmpeg;
import com.facebook.react.bridge.*;
import com.github.hiteshsondhi88.libffmpeg.LoadBinaryResponseHandler;
import com.github.hiteshsondhi88.libffmpeg.exceptions.FFmpegCommandAlreadyRunningException;
import com.github.hiteshsondhi88.libffmpeg.exceptions.FFmpegNotSupportedException;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintWriter;

public class RNReactNativeTsToMp4Module extends ReactContextBaseJavaModule {

    private static final String E_FFMPEG_NOT_LOADED = "E_FFMPEG_NOT_LOADED";
    private static final String E_FFMPEG_TRANSCODING_ERROR = "E_FFMPEG_TRANSCODING_ERROR";
    private static final String E_INPUT_FILES_NOT_FOUND = "E_INPUT_FILES_NOT_FOUND";
    private static final String E_FFMPEG_ALREADY_RUNNING = "E_FFMPEG_ALREADY_RUNNING";

    private static final String LIST_OF_EVENT_CHUNKS_TO_TRANSCODE = "eventChunksToTranscode.txt";

    private final FFmpeg fFmpeg;

    public RNReactNativeTsToMp4Module(ReactApplicationContext reactContext) {
        super(reactContext);
        fFmpeg = FFmpeg.getInstance(getReactApplicationContext());
    }

    @Override
    public String getName() {
        return "RNReactNativeTsToMp4";
    }

    @ReactMethod
    public void convert(ReadableArray tsFiles, String mp4Output, ReadableMap options, final Promise promise) {

        try {
            loadFfmpegBinary(mp4Output, tsFiles, options.getString("oauthToken"), options.getString("ffmpegBinaryURL"), promise);
        } catch (FFmpegNotSupportedException e) {
            promise.reject(E_FFMPEG_NOT_LOADED, e);
        }
    }

    private void loadFfmpegBinary(final String mp4Output, final ReadableArray tsFiles, String oauthToken, String ffmpegBinaryURL, final Promise promise) throws FFmpegNotSupportedException {
        fFmpeg.loadBinary(new LoadBinaryResponseHandler() {
            @Override
            public void onFailure() {
                promise.reject(E_FFMPEG_NOT_LOADED, new UnableToLoadFfmpegException());
            }

            @Override
            public void onSuccess() {
                startTranscoding(mp4Output, tsFiles, promise);
            }
        }, ffmpegBinaryURL, oauthToken);
    }

    private File getDecryptedHlsFilesLocation(ReadableArray tsFiles) throws FileNotFoundException {
        if (tsFiles.size() > 0) {
            String firstChunk = tsFiles.getString(0);
            File file = new File(firstChunk);
            return file.getParentFile();
        }
        throw new FileNotFoundException("tsFiles not available");
    }


    private void startTranscoding(String mp4Output, final ReadableArray tsFiles, final Promise promise) {
        try {
            File listOfEventChunksToTranscodeFile = createFileOfEventChunksToTranscode(tsFiles);
            String[] ffmpegCommand = String.format("-y -f concat -safe 0 -i %s -vcodec copy -acodec aac %s",
                listOfEventChunksToTranscodeFile.getAbsolutePath(), mp4Output
            ).split(" ");

            fFmpeg.execute(ffmpegCommand, new ExecuteBinaryResponseHandler() {
                @Override
                public void onFailure(String error) {
                    promise.reject(E_FFMPEG_TRANSCODING_ERROR, new FfmpegTranscodingException(error));
                }

                @Override
                public void onSuccess(String message) {
                    clear(tsFiles);
                    promise.resolve(message);
                }
            });
        } catch (FileNotFoundException e) {
            promise.reject(E_INPUT_FILES_NOT_FOUND, e);
        } catch (FFmpegCommandAlreadyRunningException e) {
            promise.reject(E_FFMPEG_ALREADY_RUNNING, e);

        }
    }

    private void clear(ReadableArray tsFiles) {
        for (Object tsFile : tsFiles.toArrayList()) {
            new File(tsFile.toString()).delete();
        }
    }


    private File createFileOfEventChunksToTranscode(ReadableArray tsFiles) throws FileNotFoundException {
        File decryptedHlsFilesLocation = getDecryptedHlsFilesLocation(tsFiles);
        File listOfEventChunksToTranscodeFileLocation = new File(decryptedHlsFilesLocation, LIST_OF_EVENT_CHUNKS_TO_TRANSCODE);
        PrintWriter printWriter = new PrintWriter(
            new FileOutputStream(listOfEventChunksToTranscodeFileLocation, false));

        for (Object tsFileAbsolutePath : tsFiles.toArrayList()) {
            printWriter.println(String.format("file %s", tsFileAbsolutePath.toString()));
        }
        printWriter.flush();
        printWriter.close();
        return listOfEventChunksToTranscodeFileLocation;
    }
}
