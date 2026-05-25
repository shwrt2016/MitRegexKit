//
//  MitRegexState.swift
//  MitRegexKit
//
//  校验结果状态枚举。
//  对应 OC 版 MitRegx 中的 MitRegexStateType，按字段语义分组组织。
//

import Foundation

/// 校验状态枚举。每个 case 表示一种校验结果（含成功与各类失败原因）。
public enum MitRegexState: Equatable {

    // 手机号
    case phoneRight
    case phoneTooLong       // 输入位数大于期望位数
    case phoneTooShort      // 输入位数小于期望位数
    case phoneFormatError   // 位数等于期望但含非数字字符

    // 密码
    case passwordRight
    case passwordTooShort   // 小于最小长度
    case passwordTooLong    // 大于等于最大长度

    // 验证码
    case codeRight
    case codeError          // 位数或字符不匹配

    // 身份证
    case personalIdRight
    case personalIdError    // 长度或正则不匹配

    // 邮箱
    case emailRight
    case emailError

    // 自定义校验
    case customRight(name: String)
    case customError(name: String)

    // 初始 / 未校验
    case initial
}

public extension MitRegexState {

    /// 是否为通过状态。
    var isPassed: Bool {
        switch self {
        case .phoneRight,
             .passwordRight,
             .codeRight,
             .personalIdRight,
             .emailRight,
             .initial:
            return true
        case .customRight:
            return true
        default:
            return false
        }
    }
}
