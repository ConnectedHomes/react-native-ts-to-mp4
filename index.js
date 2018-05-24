// @flow

import { NativeModules } from 'react-native';

interface RemuxerInterface {
    convert(inputFilePaths: string, outputFilePath: string): Promise<string>;
}

const RNReactNativeTsToMp4: RemuxerInterface = NativeModules.RNReactNativeTsToMp4;

export type { RemuxerInterface };
export default RNReactNativeTsToMp4;
