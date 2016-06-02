#
# Be sure to run `pod lib lint KRWalkThrough.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KRWalkThrough'
  s.version          = '0.9.3'
  s.summary          = 'Easily show tutorial anywhere in your project with the minimal amount of code to obstruct the regular app flow.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
By including KRWalkThrough into your project, you can easily build a walk through 
without polluting your code with walk through code, which is most likely used in the
app only once.

Using TutorialManager, a singleton object that will overlay the walk through on top of
your regular views, you can control the next steps of the walk through easily.
                       DESC

  s.homepage         = 'https://github.com/BridgeTheGap/KRWalkThrough'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Josh Woomin Park' => 'wmpark@knowre.com' }
  s.source           = { :git => 'https://github.com/BridgeTheGap/KRWalkThrough.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.frameworks = 'UIKit'
  s.ios.deployment_target = '8.0'
  s.source_files = 'KRWalkThrough/Classes/**/*'
  
  # s.resource_bundles = {
  #   'KRWalkThrough' => ['KRWalkThrough/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  
end
