//
//  MitRegexMaker.swift
//  MitRegexKit
//
//  链式校验构造器。对应 OC 版 MitRegexMaker。
//  使用方式：
//      let maker = MitRegexMaker()
//          .validatePhone("15941281116")
//          .validateEmail("a@b.cc")
//      print(maker.isPassed, maker.statusString)
//
//  与原 OC 版本一致：一旦某条校验失败，后续校验会被跳过，状态停留在第一个失败点。
//

import Foundation

public final class MitRegexMaker {

    /// 默认手机号位数（11 位，可被 `validatePhone(_:length:)` 临时覆盖）。
    public var phoneLength: Int = 11

    /// 默认验证码位数（6 位，可被 `validateCode(_:length:)` 临时覆盖）。
    public var codeLength: Int = 6

    /// 密码最小长度，默认 6（含）。
    public var passwordMinLength: Int = 6

    /// 密码最大长度，默认 25（不含，与 OC 原版保持一致）。
    public var passwordMaxLength: Int = 25

    /// 文案配置。
    public var message: MitRegexMessage = .default

    /// 当前校验状态。
    public private(set) var status: MitRegexState = .initial

    /// 是否所有校验均通过。任意一次失败后会变 `false`。
    public var isPassed: Bool { status.isPassed }

    /// 状态对应的可读文本。
    public var statusString: String { describe(status) }

    public init() {}

    // MARK: - 链式 API

    /// 校验手机号。`length` 不传则使用 `phoneLength`。
    @discardableResult
    public func validatePhone(_ value: String, length: Int? = nil) -> MitRegexMaker {
        if let length = length, length > 0 {
            phoneLength = length
        }
        return apply(MitRegexValidator.validatePhone(value, length: phoneLength))
    }

    /// 校验密码。
    @discardableResult
    public func validatePassword(_ value: String) -> MitRegexMaker {
        let result = MitRegexValidator.validatePassword(
            value,
            minLength: passwordMinLength,
            maxLength: passwordMaxLength
        )
        return apply(result)
    }

    /// 校验数字验证码。`length` 不传则使用 `codeLength`。
    @discardableResult
    public func validateCode(_ value: String, length: Int? = nil) -> MitRegexMaker {
        if let length = length, length > 0 {
            codeLength = length
        }
        return apply(MitRegexValidator.validateCode(value, length: codeLength))
    }

    /// 校验身份证号。
    @discardableResult
    public func validatePersonalId(_ value: String) -> MitRegexMaker {
        return apply(MitRegexValidator.validatePersonalId(value))
    }

    /// 校验邮箱。
    @discardableResult
    public func validateEmail(_ value: String) -> MitRegexMaker {
        return apply(MitRegexValidator.validateEmail(value))
    }

    /// 自定义正则校验。`name` 用于失败时拼接提示文本。
    @discardableResult
    public func validate(
        _ value: String,
        pattern: String,
        name: String
    ) -> MitRegexMaker {
        let isMatch = MitRegexValidator.matches(value, pattern: pattern)
        let result: MitRegexState = isMatch ? .customRight(name: name) : .customError(name: name)
        return apply(result)
    }

    /// 自定义条件校验。便于把任何业务判断接入链式调用。
    @discardableResult
    public func validate(
        _ name: String,
        passed: @autoclosure () -> Bool
    ) -> MitRegexMaker {
        let result: MitRegexState = passed() ? .customRight(name: name) : .customError(name: name)
        return apply(result)
    }

    // MARK: - 内部实现

    /// 短路逻辑：仅在之前未失败时才更新状态。
    @discardableResult
    private func apply(_ next: MitRegexState) -> MitRegexMaker {
        guard isPassed else { return self }
        status = next
        return self
    }

    /// 把状态枚举转为可读文本。集中处理便于本地化与维护。
    private func describe(_ state: MitRegexState) -> String {
        switch state {
        case .initial:
            return message.initial
        case .phoneRight:
            return message.phoneRight
        case .phoneTooLong:
            return String(format: message.phoneTooLongFormat, phoneLength)
        case .phoneTooShort:
            return String(format: message.phoneTooShortFormat, phoneLength)
        case .phoneFormatError:
            return message.phoneFormatError
        case .passwordRight:
            return message.passwordRight
        case .passwordTooShort:
            return message.passwordTooShort
        case .passwordTooLong:
            return message.passwordTooLong
        case .codeRight:
            return message.codeRight
        case .codeError:
            return String(format: message.codeErrorFormat, codeLength)
        case .personalIdRight:
            return message.personalIdRight
        case .personalIdError:
            return message.personalIdError
        case .emailRight:
            return message.emailRight
        case .emailError:
            return message.emailError
        case let .customRight(name):
            return String(format: message.customRightFormat, name)
        case let .customError(name):
            return String(format: message.customErrorFormat, name)
        }
    }
}
