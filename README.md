
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

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNReactNativeTsToMp4.sln` in `node_modules/react-native-react-native-ts-to-mp4/windows/RNReactNativeTsToMp4.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using React.Native.Ts.To.Mp4.RNReactNativeTsToMp4;` to the usings at the top of the file
  - Add `new RNReactNativeTsToMp4Package()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNReactNativeTsToMp4 from 'react-native-react-native-ts-to-mp4';

// TODO: What to do with the module?
RNReactNativeTsToMp4;
```
  