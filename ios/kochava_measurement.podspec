#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint kochava_measurement.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'kochava_measurement'
  s.version          = '3.2.0'
  s.summary          = 'The KochavaTracker Flutter SDK. Kochava is a leading mobile attribution and analytics platform.'
  s.description      = <<-DESC
  A lightweight and easy to integrate SDK, providing first-class integration with Kochava’s installation attribution and analytics platform.
                       DESC
  s.homepage         = 'https://www.kochava.com'
  s.license          = { :type => 'Commercial', :file => '../LICENSE' }
  s.author           = { 'Kochava' => 'sdk@kochava.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m,swift}'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.4'
  s.swift_version = '5.0'

  s.vendored_frameworks = 'Frameworks/KochavaNetworking.xcframework', 'Frameworks/KochavaMeasurement.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
