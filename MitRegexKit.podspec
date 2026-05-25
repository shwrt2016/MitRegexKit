#
# MitRegexKit.podspec
#
# 用法：
#   pod 'MitRegexKit', '~> 1.0'
# 或本地路径：
#   pod 'MitRegexKit', :path => '../MitRegexKit'
#
Pod::Spec.new do |s|
  s.name             = 'MitRegexKit'
  s.version          = '1.0.0'
  s.summary          = '基于链式调用的 Swift 校验库（手机号 / 密码 / 验证码 / 身份证 / 邮箱）'
  s.description      = <<-DESC
    MitRegexKit 受 MitRegx 启发，采用 Swift 重写。
    通过 Maker 模式与方法链支持手机号、密码、验证码、身份证、邮箱以及自定义正则的链式校验，
    并提供单条快捷校验 API。任意一条校验失败后会短路终止，便于一次拿到首个错误状态与文案。
  DESC
  s.homepage         = 'https://github.com/shwrt2016/MitRegexKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shwrt2016' => 'shwrt2016@gmail.com' }
  s.source           = { :git => 'https://github.com/shwrt2016/MitRegexKit.git', :tag => s.version.to_s }

  s.swift_versions   = ['5.7', '5.8', '5.9']

  s.ios.deployment_target     = '12.0'
  s.osx.deployment_target     = '10.13'
  s.tvos.deployment_target    = '12.0'
  s.watchos.deployment_target = '4.0'

  s.source_files     = 'Sources/MitRegexKit/**/*.swift'
  s.frameworks       = 'Foundation'
end
