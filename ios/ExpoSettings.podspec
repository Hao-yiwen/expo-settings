require 'json'

package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'ExpoSettings'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platforms      = {
    :ios => '15.1',
    :tvos => '15.1'
  }
  s.swift_version  = '5.4'
  s.source         = { git: 'https://github.com/binaryminds/react-native-sse' }

  s.dependency 'ExpoModulesCore'

  # 添加所有依赖的框架
  s.vendored_frameworks = [
    'NetworkImage.xcframework',      # 放在最前面因为其他框架依赖它
    'cmark_gfm.xcframework',
    'cmark_gfm_extensions.xcframework',
    'MarkdownUI.xcframework'         # 放在最后因为它依赖其他框架
  ]
  
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'FRAMEWORK_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)',
    'SWIFT_INCLUDE_PATHS' => [
      # cmark_gfm
      '$(PODS_TARGET_SRCROOT)/cmark_gfm.xcframework/ios-arm64/cmark_gfm.framework/Modules',
      '$(PODS_TARGET_SRCROOT)/cmark_gfm.xcframework/ios-arm64_x86_64-simulator/cmark_gfm.framework/Modules',
      # cmark_gfm_extensions
      '$(PODS_TARGET_SRCROOT)/cmark_gfm_extensions.xcframework/ios-arm64/cmark_gfm_extensions.framework/Modules',
      '$(PODS_TARGET_SRCROOT)/cmark_gfm_extensions.xcframework/ios-arm64_x86_64-simulator/cmark_gfm_extensions.framework/Modules',
      # MarkdownUI
      '$(PODS_TARGET_SRCROOT)/MarkdownUI.xcframework/ios-arm64/MarkdownUI.framework/Modules',
      '$(PODS_TARGET_SRCROOT)/MarkdownUI.xcframework/ios-arm64_x86_64-simulator/MarkdownUI.framework/Modules'
    ].join(' '),
    'HEADER_SEARCH_PATHS' => [
      # cmark_gfm
      '$(PODS_TARGET_SRCROOT)/cmark_gfm.xcframework/ios-arm64/cmark_gfm.framework/Headers',
      '$(PODS_TARGET_SRCROOT)/cmark_gfm.xcframework/ios-arm64_x86_64-simulator/cmark_gfm.framework/Headers',
      # cmark_gfm_extensions
      '$(PODS_TARGET_SRCROOT)/cmark_gfm_extensions.xcframework/ios-arm64/cmark_gfm_extensions.framework/Headers',
      '$(PODS_TARGET_SRCROOT)/cmark_gfm_extensions.xcframework/ios-arm64_x86_64-simulator/cmark_gfm_extensions.framework/Headers',
      # MarkdownUI
      '$(PODS_TARGET_SRCROOT)/MarkdownUI.xcframework/ios-arm64/MarkdownUI.framework/Headers',
      '$(PODS_TARGET_SRCROOT)/MarkdownUI.xcframework/ios-arm64_x86_64-simulator/MarkdownUI.framework/Headers',
    ].join(' '),
    'OTHER_LDFLAGS' => [
      '-framework "cmark_gfm"',
      '-framework "cmark_gfm_extensions"',
      '-framework "MarkdownUI"'
    ].join(' ')
  }

  s.source_files = "*.{h,m,mm,swift,hpp,cpp}"
  s.preserve_paths = '**/*.{framework,xcframework}'
end