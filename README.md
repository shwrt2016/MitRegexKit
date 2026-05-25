# MitRegexKit

> 受 [MitRegx](https://github.com/shwrt2016/MitRegx) 启发，使用 Swift 重写的链式校验库。

提供基于 Maker 模式的链式校验 API，支持手机号、密码、验证码、身份证、邮箱以及自定义正则。任意一条校验失败后短路终止，方便一次拿到首个错误状态与文案。

## 特性

- 纯 Swift 实现，零三方依赖（仅 Foundation）
- 链式调用：`MitRegexMaker().validatePhone(...).validateEmail(...)`
- 状态枚举 + 可读文本，文案可注入支持本地化
- 短路语义：首个失败后续校验自动跳过
- 提供 `MitRegex.isValidXxx` 等便捷单条校验入口
- 同时支持 **Swift Package Manager** 与 **CocoaPods**

## 系统要求

- iOS 12.0+ / macOS 10.13+ / tvOS 12.0+ / watchOS 4.0+
- Swift 5.7+

## 安装

### Swift Package Manager

在 Xcode 中：File → Add Packages... → 输入仓库地址。

或在 `Package.swift` 中添加：

```swift
.package(url: "https://github.com/shwrt2016/MitRegexKit.git", from: "1.0.0")
```

### CocoaPods

在 `Podfile` 中添加：

```ruby
pod 'MitRegexKit', '~> 1.0'
```

然后执行 `pod install`。

## 使用

### 单条快捷校验

```swift
import MitRegexKit

MitRegex.isValidPhone("15941281116")          // true
MitRegex.isValidEmail("foo@bar.cc")           // true
MitRegex.isValidPersonalId("11010519491231002X") // true
MitRegex.isValidCode("123456")                // true
MitRegex.isValidPassword("abc123")            // true
```

### 链式校验

```swift
let maker = MitRegexMaker()
    .validateCode("123456")
    .validatePhone("15941281116")
    .validateEmail("foo@bar.cc")
    .validatePersonalId("11010519491231002X")

print(maker.isPassed)        // true
print(maker.status)          // .personalIdRight
print(maker.statusString)    // 身份证格式正确
```

### 闭包式入口

```swift
MitRegex.make({ m in
    m.validatePhone("15941281116")
     .validateEmail("foo@bar.cc")
}) { state, text, passed in
    print(passed, state, text)
}

let state  = MitRegex.status { $0.validateEmail("foo@bar.cc") }
let text   = MitRegex.statusString { $0.validatePhone("123") }
let passed = MitRegex.isValid { $0.validatePassword("abc123") }
```

### 自定义位数

```swift
// 8 位手机号校验
MitRegexMaker().validatePhone("12345678", length: 8)

// 4 位验证码校验
MitRegexMaker().validateCode("9527", length: 4)
```

### 自定义正则与条件

```swift
MitRegexMaker()
    .validate("ABC123", pattern: "^[A-Z0-9]+$", name: "邀请码")
    .validate("年龄≥18", passed: user.age >= 18)
```

### 文案本地化

```swift
let maker = MitRegexMaker()
maker.message = MitRegexMessage(
    phoneRight: "Phone OK",
    phoneTooShortFormat: "Phone less than %d digits",
    phoneTooLongFormat: "Phone more than %d digits",
    phoneFormatError: "Phone format invalid"
)
maker.validatePhone("123")
print(maker.statusString) // Phone less than 11 digits
```

## 与 MitRegx (Objective-C) 的对照

| OC 调用 | Swift 调用 |
| --- | --- |
| `[NSObject mit_makeMitRegexMaker:^(maker){...}]` | `MitRegex.make { m in ... }` |
| `maker.validatePhone(@"...")` | `m.validatePhone("...")` |
| `maker.validatePsd(@"...")` | `m.validatePassword("...")` |
| `maker.validateCodeNumber(@"...")` | `m.validateCode("...")` |
| `maker.validatePersonalId(@"...")` | `m.validatePersonalId("...")` |
| `maker.validateEmail(@"...")` | `m.validateEmail("...")` |
| `MitRegexStateType` | `MitRegexState`（枚举） |
| `statusString` | `statusString` |
| `isPassed` | `isPassed` |

## Demo 工程

仓库内置一个 SwiftUI Demo（最低 iOS 16），打开运行即可交互式体验所有校验规则：

```bash
open Example/MitRegexKitDemo.xcodeproj
```

如需重新生成工程文件（`.xcodeproj`）：

```bash
cd Example && ruby generate_xcodeproj.rb
```

Demo 工程通过本地 Swift Package 引用根目录的库，因此在仓库内即开即用，无需任何额外依赖。

## 许可

MIT License，详见 [LICENSE](LICENSE)。
