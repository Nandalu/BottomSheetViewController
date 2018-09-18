#
# Be sure to run `pod lib lint BottomSheetViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BottomSheetViewController'
  s.version          = '1.1'
  s.summary          = 'Bottom Sheet for iOS App'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

#  s.description      = <<-DESC
#                       DESC

  s.homepage         = 'https://github.com/Nandalu/BottomSheetViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MPL 2', :file => 'LICENSE' }
  s.author           = { 'Denken Chen' => 'denkenie@gmail.com' }
  s.source           = { :git => 'https://github.com/Nandalu/BottomSheetViewController.git', :tag => s.version.to_s, submodules: true }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.2'

  s.source_files = 'BottomSheetViewController/**/*.{h,swift}'

  # s.resource_bundles = {
  #   'BottomSheetViewController' => ['BottomSheetViewController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
