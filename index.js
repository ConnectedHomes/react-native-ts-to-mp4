// @flow

import { NativeModules } from 'react-native';

export interface RemuxerInterface {
    convert(inputFilePaths: string, outputFilePath: string): Promise<string>;
}

const RNReactNativeTsToMp4: RemuxerInterface = NativeModules.RNReactNativeTsToMp4;
export default RNReactNativeTsToMp4;
