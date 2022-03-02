#
# Be sure to run `pod lib lint imgZipReName.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'imgZipReName'
  s.version          = '0.0.3'
  s.summary          = 'A short description of imgZipReName.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/songxing10000/imgZipReName'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'songxing10000' => 'songxing10000@live.cn' }
  s.source           = { :git => 'https://github.com/songxing10000/imgZipReName.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform = :osx
  s.osx.deployment_target = "10.15"
  
  s.subspec 'Source' do |ss|
  ss.source_files = 'imgZipReName/Classes/**/*.{h,m,swift}'
  ss.xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) PODSPEC_NAME=#{s.name} PODSPEC_VERSION=#{s.version}" }
  ss.resource_bundles = {
      'imgZipReName' => ['imgpiZipReName/Assets/**/*.{storyboard,xib,xcassets,json}', 'imgZipReName/Classes/**/*.{xib}']
  }
  

  end
  s.swift_version = "5.0"
  s.dependency 'ZIPFoundation', '~> 0.9.12'

#  s.subspec 'Framework' do |ss|
#       ss.ios.vendored_framework = '二进制路径'
#       ss.dependency 'ZIPFoundation', '~> 0.9.12'
#    end
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'Cocoa'
  # s.dependency 'AFNetworking', '~> 2.3'

end

