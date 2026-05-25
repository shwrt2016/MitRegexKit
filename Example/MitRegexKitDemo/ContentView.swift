//
//  ContentView.swift
//  MitRegexKitDemo
//
//  演示 MitRegexKit 的链式校验与单条快捷校验。
//  上半部分显示各字段独立的实时校验结果（绿勾 / 红叉），
//  下半部分使用 Maker 链式校验，展示首个失败短路语义。
//

import SwiftUI
import MitRegexKit

struct ContentView: View {

    @State private var phone: String = "15941281116"
    @State private var email: String = "demo@mitregex.cc"
    @State private var password: String = "abc123"
    @State private var code: String = "123456"
    @State private var personalId: String = "11010519491231002X"

    @State private var locale: MitRegexLocale = .current
    @State private var chainState: MitRegexState = .initial
    @State private var chainResultText: String = MitRegexLocale.current.message.initial
    @State private var chainPassed: Bool = false

    /// 当前语种文案，所有动态文本都通过它格式化。
    private var message: MitRegexMessage { locale.message }

    var body: some View {
        NavigationStack {
            Form {
                localeSection
                singleSection
                chainSection
                codeSamplesSection
            }
            .navigationTitle("MitRegexKit Demo")
        }
    }

    // MARK: - 语言切换

    private var localeSection: some View {
        Section("Language / 语言") {
            Picker("Locale", selection: $locale) {
                ForEach(MitRegexLocale.allCases, id: \.self) { locale in
                    Text(label(for: locale)).tag(locale)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: locale) { _ in
                refreshChainResult()
            }
        }
    }

    private func label(for locale: MitRegexLocale) -> String {
        switch locale {
        case .simplifiedChinese:  return "简体中文"
        case .traditionalChinese: return "繁體中文"
        case .english:            return "English"
        case .japanese:           return "日本語"
        case .korean:             return "한국어"
        case .turkish:            return "Türkçe"
        case .vietnamese:         return "Tiếng Việt"
        case .thai:               return "ภาษาไทย"
        }
    }

    // MARK: - 单条实时校验

    private var singleSection: some View {
        Section("MitRegex.isValidXxx") {
            field(icon: "phone.fill",                 text: $phone,      valid: MitRegex.isValidPhone(phone))
            field(icon: "envelope.fill",              text: $email,      valid: MitRegex.isValidEmail(email))
            field(icon: "lock.fill",                  text: $password,   valid: MitRegex.isValidPassword(password))
            field(icon: "number",                     text: $code,       valid: MitRegex.isValidCode(code))
            field(icon: "person.text.rectangle.fill", text: $personalId, valid: MitRegex.isValidPersonalId(personalId))
        }
    }

    private func field(icon: String, text: Binding<String>, valid: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24, alignment: .center)
                .foregroundStyle(.secondary)
            TextField("", text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Image(systemName: valid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(valid ? .green : .red)
        }
    }

    // MARK: - 链式校验

    private var chainSection: some View {
        Section("链式校验（MitRegexMaker 短路语义）") {
            Button {
                runChainValidation()
            } label: {
                Label("Validate All", systemImage: "checkmark.shield.fill")
            }

            HStack(alignment: .top) {
                Image(systemName: chainPassed ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(chainPassed ? .green : .orange)
                Text(chainResultText)
                    .font(.callout)
            }
        }
    }

    private func runChainValidation() {
        let maker = makeChainMaker()
        chainState = maker.status
        chainResultText = maker.statusString
        chainPassed = maker.isPassed
    }

    /// 切换语言后重新格式化最近一次结果，无需重新校验。
    private func refreshChainResult() {
        guard chainState != .initial else {
            chainResultText = message.initial
            return
        }
        let maker = makeChainMaker()
        chainResultText = maker.statusString
        chainPassed = maker.isPassed
    }

    /// 构造一个使用当前语种文案的 Maker，集中表达「文案随 locale 变化」。
    private func makeChainMaker() -> MitRegexMaker {
        let maker = MitRegexMaker()
        maker.message = message
        return maker
            .validateCode(code)
            .validatePhone(phone)
            .validateEmail(email)
            .validatePassword(password)
            .validatePersonalId(personalId)
    }

    // MARK: - 代码示例

    private var codeSamplesSection: some View {
        Section("API 示例") {
            sample("""
            // 单条快捷
            MitRegex.isValidPhone("15941281116")
            MitRegex.isValidEmail("a@b.cc")
            """)

            sample("""
            // 链式 + 短路
            MitRegexMaker()
              .validatePhone(phone)
              .validateEmail(email)
            """)

            sample("""
            // 闭包 + 回调
            MitRegex.make({ m in
              m.validatePhone(phone).validateEmail(email)
            }) { state, text, passed in ... }
            """)
        }
    }

    private func sample(_ text: String) -> some View {
        Text(text)
            .font(.system(.footnote, design: .monospaced))
            .foregroundStyle(.secondary)
    }
}

#Preview {
    ContentView()
}
