// @flow

const rn = require('react-native');

export interface RemuxerInterface {
    convert(inputFilePaths: string, outputFilePath: string): Promise<string>;
}

const RNReactNativeTsToMp4: RemuxerInterface = rn.NativeModules.RNReactNativeTsToMp4;

module.exports = RNReactNativeTsToMp4;
