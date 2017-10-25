#
#  Be sure to run `pod spec lint KBFormSheetController.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "KBFormSheetController"
  s.version      = "0.0.1"
  s.summary      = "KBFormSheetController."
  s.author             = "xiaoxiong"
  s.social_media_url   = "821859554@qq.com"
  s.description  = <<-DESC
                    This is KBFormSheetController.
                   DESC

  s.homepage     = "ssh://git@xxx/xxx:2020/iOS/KBFormSheetController.git"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "ssh://git@xxx/xxx:2020/iOS/KBFormSheetController.git", :tag => "#{s.version}" }

  s.source_files  = "KBFormSheetController/KBFormSheetController/**/*.{h,m}"
  s.frameworks = "CoreGraphics", "UIKit"
  s.requires_arc = true

end
