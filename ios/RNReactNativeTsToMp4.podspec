
Pod::Spec.new do |s|
  s.name         = "RNReactNativeTsToMp4"
  s.version      = "1.1.1"
  s.summary      = "RNReactNativeTsToMp4"
  s.description  = <<-DESC
                  React-Native library for converting bunch of TS files into MP4
                   DESC
  s.homepage     = "https://github.com/ConnectedHomes/react-native-ts-to-mp4"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/RNReactNativeTsToMp4.git", :tag => "master" }
  s.source_files  = "RNReactNativeTsToMp4/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  