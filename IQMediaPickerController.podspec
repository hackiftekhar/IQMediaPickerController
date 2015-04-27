Pod::Spec.new do |s|
  s.name         = "IQMediaPickerController"
  s.version      = "1.0.0"
  s.summary      = "Audio Video and Image Picker Controller"
  s.homepage     = "https://github.com/hackiftekhar/IQMediaPickerController"
  s.license      = 'MIT'
  s.author       = { "Iftekhar Qurashi" => "hack.iftekhar@gmail.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/hackiftekhar/IQMediaPickerController.git", :tag => "v1.0.0" }
  s.source_files = 'Classes', 'MediaPickerController/IQMediaPickerController/**/*.{h,m}'
  s.resources    = "MediaPickerController/IQMediaPickerController/**/*.{xcassets}"
  s.requires_arc = true
end