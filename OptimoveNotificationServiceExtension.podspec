Pod::Spec.new do |s|
  s.name             = 'OptimoveNotificationServiceExtension'
  s.version          = '6.1.0'
  s.summary          = 'Official Optimove SDK for iOS. Notification service extension framework.'
  s.description      = 'The notification service extension is used for handling additional content in push notifications.'
  s.homepage         = 'https://github.com/optimove-tech/Optimove-SDK-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mobius Solutions' => 'mobile@optimove.com' }
  s.source           = { :git => 'https://github.com/optimove-tech/Optimove-SDK-iOS.git', :tag => s.version.to_s }
  s.platform = 'ios'
  s.ios.deployment_target = '10.0'
  s.swift_version = '5'
  base_dir = "OptimoveNotificationServiceExtension/"
  s.source_files = base_dir + 'Sources/**/*', 'OptimobileShared/**/*'
  s.resource_bundles = {
    'OptimoveNotificationServiceExtension' => ['OptimoveNotificationServiceExtension/PrivacyInfo.xcprivacy']
  }
  s.frameworks = 'Foundation', 'UserNotifications', 'UIKit'
end
