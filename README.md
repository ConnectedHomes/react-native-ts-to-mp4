
# react-native-react-native-ts-to-mp4

## Getting started

`$ npm install react-native-react-native-ts-to-mp4 --save`

### Mostly automatic installation

`$ react-native link react-native-react-native-ts-to-mp4`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-react-native-ts-to-mp4` and add `RNReactNativeTsToMp4.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNReactNativeTsToMp4.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNReactNativeTsToMp4Package;` to the imports at the top of the file
  - Add `new RNReactNativeTsToMp4Package()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-react-native-ts-to-mp4'
  	project(':react-native-react-native-ts-to-mp4').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-react-native-ts-to-mp4/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-react-native-ts-to-mp4')
  	```

## Usage
```javascript
import RNReactNativeTsToMp4 from 'react-native-react-native-ts-to-mp4';

RNReactNativeTsToMp4.convert(tsFilesArray, output);
```
  
## Dev Notes

### Android

The underlying android library is `bravobit/FFmpeg-Android` (our backup fork: `ConnectedHomes/FFmpeg-Android`). Because it is not published to Maven etc (because it is itself a fork of an outdated library already in Maven) the way to integrate `bravobit/FFmpeg-Android` is clone/checkout that repo seperately and then build it with android studio or gradle. the output of that will be an `aar` in `build/outputs` folder which will then need to be copied over into `android/libs/FFmpegAndroid.aar` in this repo. 

Note that the current FFmpegAndroid.aar was compiled from `bravobit/FFmpeg-Android@2a77b5e7d822ea75672e9b2c19ff5e1f7957252b` and is a relatively "fat" binary with many compiled extra extensions that we don't need.