// @flow

const rn = require('react-native');

interface RemuxerInterface {
    convert(inputFilePaths: string, outputFilePath: string, options: { oauthToken: string, ffmpegBinaryURL: string }): Promise<string>;
}

const RNReactNativeTsToMp4: RemuxerInterface = rn.NativeModules.RNReactNativeTsToMp4;

export type { RemuxerInterface };
module.exports = RNReactNativeTsToMp4;
