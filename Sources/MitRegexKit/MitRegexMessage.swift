//
//  MitRegexMessage.swift
//  MitRegexKit
//
//  状态对应的可读文本。允许业务方按需替换文案以支持本地化。
//

import Foundation

/// 状态文案配置。所有字段都暴露给外部，便于注入本地化文案。
///
/// 含 %d 占位符的字段在格式化时会拼接当前期望位数（如手机号 11 位、验证码 6 位）。
public struct MitRegexMessage {

    public var phoneRight: String
    public var phoneTooLongFormat: String       // %d 期望位数
    public var phoneTooShortFormat: String      // %d 期望位数
    public var phoneFormatError: String

    public var passwordRight: String
    public var passwordTooShort: String
    public var passwordTooLong: String

    public var codeRight: String
    public var codeErrorFormat: String          // %d 期望位数

    public var personalIdRight: String
    public var personalIdError: String

    public var emailRight: String
    public var emailError: String

    public var customRightFormat: String        // %@ 自定义规则名
    public var customErrorFormat: String        // %@ 自定义规则名

    public var initial: String

    public init(
        phoneRight: String = "手机号格式正确",
        phoneTooLongFormat: String = "手机号位数超过 %d 位",
        phoneTooShortFormat: String = "手机号位数不足 %d 位",
        phoneFormatError: String = "手机号格式错误",
        passwordRight: String = "密码格式正确",
        passwordTooShort: String = "密码位数太少",
        passwordTooLong: String = "密码位数太多",
        codeRight: String = "验证码格式正确",
        codeErrorFormat: String = "验证码必须为 %d 位数字",
        personalIdRight: String = "身份证格式正确",
        personalIdError: String = "身份证格式错误",
        emailRight: String = "邮箱格式正确",
        emailError: String = "邮箱格式错误",
        customRightFormat: String = "%@ 校验通过",
        customErrorFormat: String = "%@ 校验未通过",
        initial: String = "未开始校验"
    ) {
        self.phoneRight = phoneRight
        self.phoneTooLongFormat = phoneTooLongFormat
        self.phoneTooShortFormat = phoneTooShortFormat
        self.phoneFormatError = phoneFormatError
        self.passwordRight = passwordRight
        self.passwordTooShort = passwordTooShort
        self.passwordTooLong = passwordTooLong
        self.codeRight = codeRight
        self.codeErrorFormat = codeErrorFormat
        self.personalIdRight = personalIdRight
        self.personalIdError = personalIdError
        self.emailRight = emailRight
        self.emailError = emailError
        self.customRightFormat = customRightFormat
        self.customErrorFormat = customErrorFormat
        self.initial = initial
    }

    /// 默认文案。从 1.1 起自动跟随系统语言（`.auto`），未匹配的语言回落英文。
    /// 如需固定语言，请使用 `.for(_:)` 或 `MitRegexLocale.<lang>.message`。
    public static var `default`: MitRegexMessage { .auto }

    /// 跟随系统语言的文案。每次访问都会重新读取，便于切换语言后即时生效。
    public static var auto: MitRegexMessage { MitRegexLocale.current.message }

    /// 指定语种文案。等价于 `locale.message`。
    public static func `for`(_ locale: MitRegexLocale) -> MitRegexMessage {
        locale.message
    }
}
