
Pod::Spec.new do |s|
  s.name         = "RNReactNativeTsToMp4"
  s.version      = "1.0.0"
  s.summary      = "RNReactNativeTsToMp4"
  s.description  = <<-DESC
                  RNReactNativeTsToMp4
                   DESC
  s.homepage     = ""
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

  