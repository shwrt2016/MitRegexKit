//
//  MitRegexValidator.swift
//  MitRegexKit
//
//  纯校验逻辑实现，与 Maker 的链式调用解耦。
//  方便外部直接复用单条规则，也方便在 Maker 内部组合。
//

import Foundation

/// 内部校验器集合，提供原子的 (输入 -> 状态) 函数。
public enum MitRegexValidator {

    // MARK: 手机号

    /// 校验手机号。仅做位数和数字字符校验，业务可通过 `length` 参数定制。
    public static func validatePhone(_ value: String, length: Int = 11) -> MitRegexState {
        let expected = length > 0 ? length : 11
        let count = value.count
        if count == expected, allDigits(value) {
            return .phoneRight
        }
        if count < expected {
            return .phoneTooShort
        }
        if count > expected {
            return .phoneTooLong
        }
        return .phoneFormatError
    }

    // MARK: 密码

    /// 校验密码长度。默认范围 [minLength, maxLength)，与 OC 原版保持一致：默认 6...24。
    public static func validatePassword(
        _ value: String,
        minLength: Int = 6,
        maxLength: Int = 25
    ) -> MitRegexState {
        let count = value.count
        if count < minLength {
            return .passwordTooShort
        }
        if count >= maxLength {
            return .passwordTooLong
        }
        return .passwordRight
    }

    // MARK: 验证码

    /// 校验数字验证码。位数可定制，默认 6。
    public static func validateCode(_ value: String, length: Int = 6) -> MitRegexState {
        let expected = length > 0 ? length : 6
        if value.count == expected, allDigits(value) {
            return .codeRight
        }
        return .codeError
    }

    // MARK: 身份证

    /// 校验中国大陆身份证号（15 位旧版 / 18 位带校验位）。
    /// 18 位会校验加权校验位，15 位仅校验长度与字符。
    public static func validatePersonalId(_ value: String) -> MitRegexState {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let count = trimmed.count
        guard count == 15 || count == 18 else {
            return .personalIdError
        }
        let pattern = "^(\\d{14}|\\d{17})(\\d|[xX])$"
        guard matches(trimmed, pattern: pattern) else {
            return .personalIdError
        }
        if count == 18, !checksumValid18(trimmed) {
            return .personalIdError
        }
        return .personalIdRight
    }

    // MARK: 邮箱

    /// 校验邮箱格式。沿用经典正则，覆盖常见场景。
    public static func validateEmail(_ value: String) -> MitRegexState {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return matches(value, pattern: pattern) ? .emailRight : .emailError
    }

    // MARK: 通用辅助

    /// 是否全部为数字字符。
    public static func allDigits(_ value: String) -> Bool {
        guard !value.isEmpty else { return false }
        return value.allSatisfy { $0.isASCII && $0.isNumber }
    }

    /// NSRegularExpression 全字匹配。
    public static func matches(_ value: String, pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        return regex.firstMatch(in: value, options: [], range: range) != nil
    }
}

// MARK: - 18 位身份证校验位算法

private extension MitRegexValidator {

    /// 18 位身份证最后一位校验码计算（GB 11643-1999）。
    static func checksumValid18(_ value: String) -> Bool {
        let weights = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        let codes = ["1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"]
        let chars = Array(value)
        var sum = 0
        for index in 0..<17 {
            guard let digit = chars[index].wholeNumberValue else { return false }
            sum += digit * weights[index]
        }
        let expected = codes[sum % 11]
        let actual = String(chars[17]).uppercased()
        return expected == actual
    }
}
