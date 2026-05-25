//
//  MitRegex.swift
//  MitRegexKit
//
//  顶层便捷入口。等价于 OC 版 NSObject (mitRegexMaker) 分类。
//

import Foundation

/// 顶层命名空间，承载所有便捷入口。
public enum MitRegex {

    /// 闭包式构造一个 `MitRegexMaker`，便于在一行内执行多条校验。
    ///
    ///     let maker = MitRegex.make { m in
    ///         m.validatePhone("15941281116").validateEmail("a@b.cc")
    ///     }
    ///     print(maker.isPassed, maker.statusString)
    @discardableResult
    public static func make(_ build: (MitRegexMaker) -> Void) -> MitRegexMaker {
        let maker = MitRegexMaker()
        build(maker)
        return maker
    }

    /// 一次校验后，将状态、文本、是否通过通过回调返回。
    public static func make(
        _ build: (MitRegexMaker) -> Void,
        completion: (MitRegexState, String, Bool) -> Void
    ) {
        let maker = make(build)
        completion(maker.status, maker.statusString, maker.isPassed)
    }

    /// 仅返回状态码。
    public static func status(_ build: (MitRegexMaker) -> Void) -> MitRegexState {
        return make(build).status
    }

    /// 仅返回状态文本。
    public static func statusString(_ build: (MitRegexMaker) -> Void) -> String {
        return make(build).statusString
    }

    /// 仅返回是否通过。
    public static func isValid(_ build: (MitRegexMaker) -> Void) -> Bool {
        return make(build).isPassed
    }
}

// MARK: - 便捷单字段校验

public extension MitRegex {

    /// 单独校验手机号是否格式正确。
    static func isValidPhone(_ value: String, length: Int = 11) -> Bool {
        return MitRegexValidator.validatePhone(value, length: length) == .phoneRight
    }

    /// 单独校验邮箱。
    static func isValidEmail(_ value: String) -> Bool {
        return MitRegexValidator.validateEmail(value) == .emailRight
    }

    /// 单独校验身份证。
    static func isValidPersonalId(_ value: String) -> Bool {
        return MitRegexValidator.validatePersonalId(value) == .personalIdRight
    }

    /// 单独校验数字验证码。
    static func isValidCode(_ value: String, length: Int = 6) -> Bool {
        return MitRegexValidator.validateCode(value, length: length) == .codeRight
    }

    /// 单独校验密码。
    static func isValidPassword(_ value: String, minLength: Int = 6, maxLength: Int = 25) -> Bool {
        let result = MitRegexValidator.validatePassword(value, minLength: minLength, maxLength: maxLength)
        return result == .passwordRight
    }
}
