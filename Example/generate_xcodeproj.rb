#!/usr/bin/env ruby
# frozen_string_literal: true
#
# 用 xcodeproj gem 生成 MitRegexKitDemo.xcodeproj。
# 关键点：通过 XCLocalSwiftPackageReference 引用上级目录的 Package.swift，
# 使 Demo 直接基于本地 SwiftPM 包，而不是写死路径或拷贝源码。
#
# 用法：
#   cd Example && ruby generate_xcodeproj.rb
#

require 'xcodeproj'
require 'fileutils'

example_dir = File.expand_path(__dir__)
project_path = File.join(example_dir, 'MitRegexKitDemo.xcodeproj')
target_name  = 'MitRegexKitDemo'
bundle_id    = 'com.mitregexkit.demo'
deployment   = '16.0'

# 重新生成时清掉旧工程，避免遗留状态。
FileUtils.rm_rf(project_path)

project = Xcodeproj::Project.new(project_path)

# Project 级别构建配置：开启模块、Swift 5。
project.build_configurations.each do |config|
  config.build_settings.merge!(
    'IPHONEOS_DEPLOYMENT_TARGET' => deployment,
    'SWIFT_VERSION'              => '5.0',
    'CLANG_ENABLE_MODULES'       => 'YES',
    'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
  )
end

# 主 group：MitRegexKitDemo。
demo_group = project.main_group.new_group(target_name, target_name)

%w[
  MitRegexKitDemoApp.swift
  ContentView.swift
].each do |file|
  demo_group.new_reference(file)
end

assets_ref = demo_group.new_reference('Assets.xcassets')
preview_group = demo_group.new_group('Preview Content', 'Preview Content')
preview_assets_ref = preview_group.new_reference('Preview Assets.xcassets')

# 创建 iOS App target。
target = project.new_target(:application, target_name, :ios, deployment)

# 编译源文件加入 Sources Build Phase。
target.source_build_phase.add_file_reference(demo_group.files.find { |f| f.path == 'MitRegexKitDemoApp.swift' })
target.source_build_phase.add_file_reference(demo_group.files.find { |f| f.path == 'ContentView.swift' })

# Asset Catalogs 加入 Resources Build Phase。
target.resources_build_phase.add_file_reference(assets_ref)
target.resources_build_phase.add_file_reference(preview_assets_ref)

# 配置 Target 构建设置：使用 Generated Info.plist + SwiftUI App 入口。
target.build_configurations.each do |config|
  config.build_settings.merge!(
    'PRODUCT_BUNDLE_IDENTIFIER' => bundle_id,
    'PRODUCT_NAME'              => '$(TARGET_NAME)',
    'TARGETED_DEVICE_FAMILY'    => '1,2',
    'IPHONEOS_DEPLOYMENT_TARGET' => deployment,
    'SWIFT_VERSION'             => '5.0',
    'CLANG_ENABLE_MODULES'      => 'YES',

    # Generated Info.plist：避免维护单独的 Info.plist 文件。
    'GENERATE_INFOPLIST_FILE'                                            => 'YES',
    'INFOPLIST_KEY_UIApplicationSceneManifest_Generation'                => 'YES',
    'INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents'             => 'YES',
    'INFOPLIST_KEY_UILaunchScreen_Generation'                            => 'YES',
    'INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone'              => 'UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight',
    'INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad'                => 'UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight',

    # 资产 Catalog 颜色与图标。
    'ASSETCATALOG_COMPILER_APPICON_NAME'      => 'AppIcon',
    'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME' => 'AccentColor',

    # SwiftUI Preview Content。
    'DEVELOPMENT_ASSET_PATHS'                 => "\"#{target_name}/Preview Content\"",
    'ENABLE_PREVIEWS'                         => 'YES',

    # 关闭代码签名以便 xcodebuild build 验证。
    'CODE_SIGN_STYLE'    => 'Automatic',
    'CODE_SIGNING_REQUIRED' => 'NO',
    'CODE_SIGNING_ALLOWED'  => 'NO'
  )
end

# 引用上级目录的本地 Swift Package。
local_pkg = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
local_pkg.relative_path = '..'
project.root_object.package_references << local_pkg

product_dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
product_dep.product_name = 'MitRegexKit'
product_dep.package = local_pkg

target.package_product_dependencies ||= []
target.package_product_dependencies << product_dep

# 把 product_ref 加入 Frameworks Build Phase，确保链接。
build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
build_file.product_ref = product_dep
target.frameworks_build_phase.files << build_file

project.save

puts "Generated #{project_path}"
