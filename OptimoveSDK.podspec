Pod::Spec.new do |s|
  s.name             = 'OptimoveSDK'
  s.version          = '6.1.0'
  s.summary          = 'Official Optimove SDK for iOS.'
  s.description      = 'The Optimove SDK framework is used for reporting events and receive push notifications.'
  s.homepage         = 'https://github.com/optimove-tech/Optimove-SDK-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mobius Solutions' => 'mobile@optimove.com' }
  s.source           = { :git => 'https://github.com/optimove-tech/Optimove-SDK-iOS.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Optimove'
  s.platform = 'ios'
  s.ios.deployment_target = '10.0'
  # s.static_framework = true
  s.swift_version = '5'
  base_dir = "OptimoveSDK/"
  s.source_files = base_dir + 'Sources/Classes/**/*', 'OptimobileShared/**/*'
  s.resource_bundles = {
    'OptimoveSDK' => ['OptimoveSDK/PrivacyInfo.xcprivacy']
  }
  s.dependency 'OptimoveCore', s.version.to_s
  s.frameworks = 'Foundation', 'UIKit', 'SystemConfiguration', 'UserNotifications', 'CoreData'
end
