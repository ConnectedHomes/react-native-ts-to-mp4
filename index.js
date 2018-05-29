// @flow

const rn = require('react-native');

interface RemuxerInterface {
    convert(inputFilePaths: string, outputFilePath: string): Promise<string>;
}

const RNReactNativeTsToMp4: RemuxerInterface = rn.NativeModules.RNReactNativeTsToMp4;

export type { RemuxerInterface };
module.export = RNReactNativeTsToMp4;
