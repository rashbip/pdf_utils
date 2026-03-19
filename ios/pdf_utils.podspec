Pod::Spec.new do |s|
  s.name             = 'pdf_utils'
  s.version          = '2.1.0'
  s.summary          = 'A comprehensive Flutter plugin for PDF manipulation, including professional invoice generation, image-to-PDF conversion, and PDF-to-image extraction.'
  s.description      = <<-DESC
A comprehensive Flutter plugin for PDF manipulation, including professional invoice generation, image-to-PDF conversion, and PDF-to-image extraction.
                       DESC
  s.homepage         = 'https://github.com/rashbip/pdf_utils'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'BiplobORG' => 'biplob2055bd@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
