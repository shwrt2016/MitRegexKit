//
//  MitRegexLocale.swift
//  MitRegexKit
//
//  内置 8 种语言文案与系统语言自动检测。
//  当前版本支持：
//      简体中文 / 繁体中文 / English / 日本語 / 한국어 / Türkçe / Tiếng Việt / ภาษาไทย
//
//  Format 字段保留 OC 风格占位符（%d / %@），与 MitRegexMessage 配套：
//      - `%d` 拼接位数（手机号 / 验证码）
//      - `%@` 拼接自定义校验名称
//

import Foundation

/// 内置语言枚举。`rawValue` 为 BCP-47 语言标签前缀，便于与系统 locale 匹配。
public enum MitRegexLocale: String, CaseIterable, Sendable {

    case simplifiedChinese  = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case english            = "en"
    case japanese           = "ja"
    case korean             = "ko"
    case turkish            = "tr"
    case vietnamese         = "vi"
    case thai               = "th"

    /// 该语种对应的完整文案。
    public var message: MitRegexMessage { Self.message(for: self) }

    /// 跟随系统语言，未匹配则回落英文。
    /// 每次访问都会重新读取 `Locale.preferredLanguages`，因此切换系统语言后立即生效。
    public static var current: MitRegexLocale {
        for languageCode in Locale.preferredLanguages {
            if let match = bestMatch(for: languageCode) {
                return match
            }
        }
        return .english
    }

    /// 把任意 BCP-47 语言标签匹配到内置语种。便于业务方手动按字符串选择。
    public static func bestMatch(for languageCode: String) -> MitRegexLocale? {
        let lower = languageCode.lowercased()

        // 中文需要先按变体细分，再回落简体。
        if lower.hasPrefix("zh-hans") || lower == "zh-cn" || lower == "zh-sg" || lower == "zh-my" {
            return .simplifiedChinese
        }
        if lower.hasPrefix("zh-hant") || lower == "zh-tw" || lower == "zh-hk" || lower == "zh-mo" {
            return .traditionalChinese
        }
        if lower.hasPrefix("zh") {
            return .simplifiedChinese
        }
        if lower.hasPrefix("en") { return .english }
        if lower.hasPrefix("ja") { return .japanese }
        if lower.hasPrefix("ko") { return .korean }
        if lower.hasPrefix("tr") { return .turkish }
        if lower.hasPrefix("vi") { return .vietnamese }
        if lower.hasPrefix("th") { return .thai }
        return nil
    }
}

// MARK: - 各语种文案表

private extension MitRegexLocale {

    static func message(for locale: MitRegexLocale) -> MitRegexMessage {
        switch locale {
        case .simplifiedChinese:  return zhHans
        case .traditionalChinese: return zhHant
        case .english:            return en
        case .japanese:           return ja
        case .korean:             return ko
        case .turkish:            return tr
        case .vietnamese:         return vi
        case .thai:               return th
        }
    }

    static let zhHans = MitRegexMessage(
        phoneRight: "手机号格式正确",
        phoneTooLongFormat: "手机号位数超过 %d 位",
        phoneTooShortFormat: "手机号位数不足 %d 位",
        phoneFormatError: "手机号格式错误",
        passwordRight: "密码格式正确",
        passwordTooShort: "密码位数太少",
        passwordTooLong: "密码位数太多",
        codeRight: "验证码格式正确",
        codeErrorFormat: "验证码必须为 %d 位数字",
        personalIdRight: "身份证格式正确",
        personalIdError: "身份证格式错误",
        emailRight: "邮箱格式正确",
        emailError: "邮箱格式错误",
        customRightFormat: "%@ 校验通过",
        customErrorFormat: "%@ 校验未通过",
        initial: "未开始校验"
    )

    static let zhHant = MitRegexMessage(
        phoneRight: "手機號格式正確",
        phoneTooLongFormat: "手機號位數超過 %d 位",
        phoneTooShortFormat: "手機號位數不足 %d 位",
        phoneFormatError: "手機號格式錯誤",
        passwordRight: "密碼格式正確",
        passwordTooShort: "密碼位數太少",
        passwordTooLong: "密碼位數太多",
        codeRight: "驗證碼格式正確",
        codeErrorFormat: "驗證碼必須為 %d 位數字",
        personalIdRight: "身分證格式正確",
        personalIdError: "身分證格式錯誤",
        emailRight: "郵箱格式正確",
        emailError: "郵箱格式錯誤",
        customRightFormat: "%@ 校驗通過",
        customErrorFormat: "%@ 校驗未通過",
        initial: "未開始校驗"
    )

    static let en = MitRegexMessage(
        phoneRight: "Phone number format is valid",
        phoneTooLongFormat: "Phone number exceeds %d digits",
        phoneTooShortFormat: "Phone number is less than %d digits",
        phoneFormatError: "Invalid phone number format",
        passwordRight: "Password format is valid",
        passwordTooShort: "Password is too short",
        passwordTooLong: "Password is too long",
        codeRight: "Verification code is valid",
        codeErrorFormat: "Verification code must be %d digits",
        personalIdRight: "ID number is valid",
        personalIdError: "Invalid ID number",
        emailRight: "Email format is valid",
        emailError: "Invalid email format",
        customRightFormat: "%@ passed",
        customErrorFormat: "%@ failed",
        initial: "Validation not started"
    )

    static let ja = MitRegexMessage(
        phoneRight: "電話番号の形式が正しい",
        phoneTooLongFormat: "電話番号の桁数が %d 桁を超えています",
        phoneTooShortFormat: "電話番号の桁数が %d 桁に達していません",
        phoneFormatError: "電話番号の形式が正しくありません",
        passwordRight: "パスワードの形式が正しい",
        passwordTooShort: "パスワードが短すぎます",
        passwordTooLong: "パスワードが長すぎます",
        codeRight: "認証コードの形式が正しい",
        codeErrorFormat: "認証コードは %d 桁の数字である必要があります",
        personalIdRight: "身分証番号の形式が正しい",
        personalIdError: "身分証番号の形式が正しくありません",
        emailRight: "メールアドレスの形式が正しい",
        emailError: "メールアドレスの形式が正しくありません",
        customRightFormat: "%@ の検証に成功しました",
        customErrorFormat: "%@ の検証に失敗しました",
        initial: "検証未開始"
    )

    static let ko = MitRegexMessage(
        phoneRight: "전화번호 형식이 올바릅니다",
        phoneTooLongFormat: "전화번호가 %d자리를 초과합니다",
        phoneTooShortFormat: "전화번호가 %d자리에 미치지 못합니다",
        phoneFormatError: "전화번호 형식이 올바르지 않습니다",
        passwordRight: "비밀번호 형식이 올바릅니다",
        passwordTooShort: "비밀번호가 너무 짧습니다",
        passwordTooLong: "비밀번호가 너무 깁니다",
        codeRight: "인증번호 형식이 올바릅니다",
        codeErrorFormat: "인증번호는 %d자리 숫자여야 합니다",
        personalIdRight: "신분증 형식이 올바릅니다",
        personalIdError: "신분증 형식이 올바르지 않습니다",
        emailRight: "이메일 형식이 올바릅니다",
        emailError: "이메일 형식이 올바르지 않습니다",
        customRightFormat: "%@ 검증 통과",
        customErrorFormat: "%@ 검증 실패",
        initial: "검증 시작 전"
    )

    static let tr = MitRegexMessage(
        phoneRight: "Telefon numarası formatı doğru",
        phoneTooLongFormat: "Telefon numarası %d basamağı aşıyor",
        phoneTooShortFormat: "Telefon numarası %d basamaktan az",
        phoneFormatError: "Geçersiz telefon numarası formatı",
        passwordRight: "Parola formatı doğru",
        passwordTooShort: "Parola çok kısa",
        passwordTooLong: "Parola çok uzun",
        codeRight: "Doğrulama kodu doğru",
        codeErrorFormat: "Doğrulama kodu %d basamaklı sayı olmalıdır",
        personalIdRight: "Kimlik numarası formatı doğru",
        personalIdError: "Geçersiz kimlik numarası",
        emailRight: "E-posta formatı doğru",
        emailError: "Geçersiz e-posta formatı",
        customRightFormat: "%@ doğrulandı",
        customErrorFormat: "%@ doğrulanamadı",
        initial: "Doğrulama başlatılmadı"
    )

    static let vi = MitRegexMessage(
        phoneRight: "Định dạng số điện thoại hợp lệ",
        phoneTooLongFormat: "Số điện thoại vượt quá %d chữ số",
        phoneTooShortFormat: "Số điện thoại ít hơn %d chữ số",
        phoneFormatError: "Định dạng số điện thoại không hợp lệ",
        passwordRight: "Định dạng mật khẩu hợp lệ",
        passwordTooShort: "Mật khẩu quá ngắn",
        passwordTooLong: "Mật khẩu quá dài",
        codeRight: "Mã xác minh hợp lệ",
        codeErrorFormat: "Mã xác minh phải có %d chữ số",
        personalIdRight: "Định dạng CMND/CCCD hợp lệ",
        personalIdError: "Định dạng CMND/CCCD không hợp lệ",
        emailRight: "Định dạng email hợp lệ",
        emailError: "Định dạng email không hợp lệ",
        customRightFormat: "%@ đã được xác thực",
        customErrorFormat: "%@ xác thực thất bại",
        initial: "Chưa bắt đầu xác thực"
    )

    static let th = MitRegexMessage(
        phoneRight: "รูปแบบหมายเลขโทรศัพท์ถูกต้อง",
        phoneTooLongFormat: "หมายเลขโทรศัพท์เกิน %d หลัก",
        phoneTooShortFormat: "หมายเลขโทรศัพท์น้อยกว่า %d หลัก",
        phoneFormatError: "รูปแบบหมายเลขโทรศัพท์ไม่ถูกต้อง",
        passwordRight: "รูปแบบรหัสผ่านถูกต้อง",
        passwordTooShort: "รหัสผ่านสั้นเกินไป",
        passwordTooLong: "รหัสผ่านยาวเกินไป",
        codeRight: "รหัสยืนยันถูกต้อง",
        codeErrorFormat: "รหัสยืนยันต้องเป็นตัวเลข %d หลัก",
        personalIdRight: "รูปแบบเลขบัตรประชาชนถูกต้อง",
        personalIdError: "รูปแบบเลขบัตรประชาชนไม่ถูกต้อง",
        emailRight: "รูปแบบอีเมลถูกต้อง",
        emailError: "รูปแบบอีเมลไม่ถูกต้อง",
        customRightFormat: "%@ ตรวจสอบผ่าน",
        customErrorFormat: "%@ ตรวจสอบไม่ผ่าน",
        initial: "ยังไม่ได้เริ่มตรวจสอบ"
    )
}
