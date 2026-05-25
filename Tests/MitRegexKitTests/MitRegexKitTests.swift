//
//  MitRegexKitTests.swift
//  MitRegexKitTests
//
//  覆盖 MitRegexKit 各校验路径的单元测试。
//

import XCTest
@testable import MitRegexKit

final class MitRegexKitTests: XCTestCase {

    // MARK: 手机号

    func test_validatePhone_default11_pass() {
        let maker = MitRegexMaker().validatePhone("15941281116")
        XCTAssertEqual(maker.status, .phoneRight)
        XCTAssertTrue(maker.isPassed)
    }

    func test_validatePhone_tooShort() {
        let maker = MitRegexMaker().validatePhone("1594128")
        XCTAssertEqual(maker.status, .phoneTooShort)
        XCTAssertFalse(maker.isPassed)
        XCTAssertTrue(maker.statusString.contains("11"))
    }

    func test_validatePhone_tooLong() {
        let maker = MitRegexMaker().validatePhone("159412811160000")
        XCTAssertEqual(maker.status, .phoneTooLong)
    }

    func test_validatePhone_formatError() {
        let maker = MitRegexMaker().validatePhone("1594128111a")
        XCTAssertEqual(maker.status, .phoneFormatError)
    }

    func test_validatePhone_customLength() {
        let maker = MitRegexMaker().validatePhone("1234567890", length: 10)
        XCTAssertEqual(maker.status, .phoneRight)
    }

    // MARK: 密码

    func test_validatePassword_pass() {
        let maker = MitRegexMaker().validatePassword("abc123")
        XCTAssertEqual(maker.status, .passwordRight)
    }

    func test_validatePassword_tooShort() {
        let maker = MitRegexMaker().validatePassword("a1")
        XCTAssertEqual(maker.status, .passwordTooShort)
    }

    func test_validatePassword_tooLong() {
        let value = String(repeating: "a", count: 25)
        let maker = MitRegexMaker().validatePassword(value)
        XCTAssertEqual(maker.status, .passwordTooLong)
    }

    // MARK: 验证码

    func test_validateCode_pass() {
        let maker = MitRegexMaker().validateCode("123456")
        XCTAssertEqual(maker.status, .codeRight)
    }

    func test_validateCode_error() {
        let maker = MitRegexMaker().validateCode("12ab56")
        XCTAssertEqual(maker.status, .codeError)
    }

    func test_validateCode_customLength() {
        let maker = MitRegexMaker().validateCode("1234", length: 4)
        XCTAssertEqual(maker.status, .codeRight)
    }

    // MARK: 身份证

    func test_validatePersonalId_18_pass() {
        // 校验码经离线公式计算正确
        let maker = MitRegexMaker().validatePersonalId("11010519491231002X")
        XCTAssertEqual(maker.status, .personalIdRight)
    }

    func test_validatePersonalId_18_checksumWrong() {
        let maker = MitRegexMaker().validatePersonalId("110105194912310021")
        XCTAssertEqual(maker.status, .personalIdError)
    }

    func test_validatePersonalId_15_pass() {
        let maker = MitRegexMaker().validatePersonalId("110105491231002")
        XCTAssertEqual(maker.status, .personalIdRight)
    }

    func test_validatePersonalId_lengthWrong() {
        let maker = MitRegexMaker().validatePersonalId("12345")
        XCTAssertEqual(maker.status, .personalIdError)
    }

    // MARK: 邮箱

    func test_validateEmail_pass() {
        let maker = MitRegexMaker().validateEmail("test_user+tag@sub.example.com")
        XCTAssertEqual(maker.status, .emailRight)
    }

    func test_validateEmail_error() {
        let maker = MitRegexMaker().validateEmail("not-an-email")
        XCTAssertEqual(maker.status, .emailError)
    }

    // MARK: 链式短路

    func test_chain_shortCircuit() {
        let maker = MitRegexMaker()
            .validateCode("12")
            .validatePhone("15941281116")
            .validateEmail("a@b.cc")

        XCTAssertEqual(maker.status, .codeError, "首个失败后应短路停留在 .codeError")
        XCTAssertFalse(maker.isPassed)
    }

    func test_chain_allPass() {
        let maker = MitRegexMaker()
            .validateCode("123456")
            .validatePhone("15941281116")
            .validateEmail("a@b.cc")
            .validatePersonalId("11010519491231002X")

        XCTAssertTrue(maker.isPassed)
        XCTAssertEqual(maker.status, .personalIdRight)
    }

    // MARK: 顶层便捷 API

    func test_topLevel_make_completion() {
        var captured: (MitRegexState, String, Bool)?
        MitRegex.make({ m in
            m.validateEmail("a@b.cc")
        }, completion: { state, text, passed in
            captured = (state, text, passed)
        })
        XCTAssertEqual(captured?.0, .emailRight)
        XCTAssertEqual(captured?.2, true)
        XCTAssertFalse(captured?.1.isEmpty ?? true)
    }

    func test_topLevel_isValidShortcuts() {
        XCTAssertTrue(MitRegex.isValidPhone("15941281116"))
        XCTAssertFalse(MitRegex.isValidPhone("159"))

        XCTAssertTrue(MitRegex.isValidEmail("foo@bar.cc"))
        XCTAssertFalse(MitRegex.isValidEmail("foo@bar"))

        XCTAssertTrue(MitRegex.isValidCode("123456"))
        XCTAssertFalse(MitRegex.isValidCode("12345"))

        XCTAssertTrue(MitRegex.isValidPassword("abc123"))
        XCTAssertFalse(MitRegex.isValidPassword("ab"))
    }

    // MARK: 自定义校验

    func test_customRegex_pass() {
        let maker = MitRegexMaker().validate(
            "ABC123",
            pattern: "^[A-Z0-9]+$",
            name: "邀请码"
        )
        XCTAssertEqual(maker.status, .customRight(name: "邀请码"))
        XCTAssertTrue(maker.statusString.contains("邀请码"))
    }

    func test_customRegex_fail() {
        let maker = MitRegexMaker().validate(
            "abc",
            pattern: "^[A-Z]+$",
            name: "大写串"
        )
        XCTAssertEqual(maker.status, .customError(name: "大写串"))
    }

    func test_customCondition_fail() {
        let maker = MitRegexMaker().validate("年龄≥18", passed: 15 >= 18)
        XCTAssertFalse(maker.isPassed)
    }

    // MARK: 文案注入

    func test_messageInjection() {
        let maker = MitRegexMaker()
        maker.message = MitRegexMessage(
            phoneRight: "OK",
            phoneTooLongFormat: "MORE than %d",
            phoneTooShortFormat: "LESS than %d",
            phoneFormatError: "BAD_FORMAT"
        )
        maker.validatePhone("123")
        XCTAssertEqual(maker.statusString, "LESS than 11")
    }

    // MARK: 多语种文案

    func test_locale_allLocalesProvideAllStrings() {
        // 任一语种的所有字段都不能为空，避免漏翻。
        for locale in MitRegexLocale.allCases {
            let m = locale.message
            XCTAssertFalse(m.phoneRight.isEmpty,         "phoneRight missing for \(locale)")
            XCTAssertFalse(m.phoneTooLongFormat.isEmpty, "phoneTooLongFormat missing for \(locale)")
            XCTAssertFalse(m.phoneTooShortFormat.isEmpty,"phoneTooShortFormat missing for \(locale)")
            XCTAssertFalse(m.phoneFormatError.isEmpty,   "phoneFormatError missing for \(locale)")
            XCTAssertFalse(m.passwordRight.isEmpty,      "passwordRight missing for \(locale)")
            XCTAssertFalse(m.passwordTooShort.isEmpty,   "passwordTooShort missing for \(locale)")
            XCTAssertFalse(m.passwordTooLong.isEmpty,    "passwordTooLong missing for \(locale)")
            XCTAssertFalse(m.codeRight.isEmpty,          "codeRight missing for \(locale)")
            XCTAssertFalse(m.codeErrorFormat.isEmpty,    "codeErrorFormat missing for \(locale)")
            XCTAssertFalse(m.personalIdRight.isEmpty,    "personalIdRight missing for \(locale)")
            XCTAssertFalse(m.personalIdError.isEmpty,    "personalIdError missing for \(locale)")
            XCTAssertFalse(m.emailRight.isEmpty,         "emailRight missing for \(locale)")
            XCTAssertFalse(m.emailError.isEmpty,         "emailError missing for \(locale)")
            XCTAssertFalse(m.customRightFormat.isEmpty,  "customRightFormat missing for \(locale)")
            XCTAssertFalse(m.customErrorFormat.isEmpty,  "customErrorFormat missing for \(locale)")
            XCTAssertFalse(m.initial.isEmpty,            "initial missing for \(locale)")
        }
    }

    func test_locale_formatPlaceholdersWork() {
        // 各语种的 phoneTooShortFormat 都应能正确替换 %d。
        for locale in MitRegexLocale.allCases {
            let maker = MitRegexMaker()
            maker.message = locale.message
            maker.validatePhone("123")
            XCTAssertTrue(maker.statusString.contains("11"), "Expected '11' in \(locale): \(maker.statusString)")
        }
    }

    func test_locale_customFormatTakesName() {
        // %@ 占位符必须能被 String 替换，不能保留 %@。
        for locale in MitRegexLocale.allCases {
            let maker = MitRegexMaker()
            maker.message = locale.message
            maker.validate("InviteCode", passed: false)
            XCTAssertTrue(maker.statusString.contains("InviteCode"), "Expected name in \(locale): \(maker.statusString)")
            XCTAssertFalse(maker.statusString.contains("%@"),         "Unreplaced %@ in \(locale): \(maker.statusString)")
        }
    }

    func test_locale_bestMatch() {
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "zh-Hans-CN"), .simplifiedChinese)
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "zh-CN"),      .simplifiedChinese)
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "zh-Hant-TW"), .traditionalChinese)
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "zh-TW"),      .traditionalChinese)
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "zh-HK"),      .traditionalChinese)
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "zh"),         .simplifiedChinese)
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "en-US"),      .english)
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "ja-JP"),      .japanese)
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "ko-KR"),      .korean)
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "tr-TR"),      .turkish)
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "vi-VN"),      .vietnamese)
        XCTAssertEqual(MitRegexLocale.bestMatch(for: "th-TH"),      .thai)
        XCTAssertNil(MitRegexLocale.bestMatch(for: "fr-FR"))
        XCTAssertNil(MitRegexLocale.bestMatch(for: "de"))
    }

    func test_locale_messageForReturnsExpectedLanguage() {
        // 抽样：英文应是 "Email format is valid"，日文应是 "メール..." 开头。
        XCTAssertEqual(MitRegexMessage.for(.english).emailRight, "Email format is valid")
        XCTAssertTrue(MitRegexMessage.for(.japanese).emailRight.contains("メール"))
        XCTAssertTrue(MitRegexMessage.for(.korean).emailRight.contains("이메일"))
        XCTAssertTrue(MitRegexMessage.for(.turkish).emailRight.contains("posta"))
        XCTAssertTrue(MitRegexMessage.for(.vietnamese).emailRight.contains("email"))
        XCTAssertTrue(MitRegexMessage.for(.thai).emailRight.contains("อีเมล"))
    }
}
