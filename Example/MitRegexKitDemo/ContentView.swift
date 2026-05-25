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

    @State private var chainResultText: String = "未开始校验"
    @State private var chainPassed: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                singleSection
                chainSection
                codeSamplesSection
            }
            .navigationTitle("MitRegexKit Demo")
        }
    }

    // MARK: - 单条实时校验

    private var singleSection: some View {
        Section("单条实时校验（MitRegex.isValidXxx）") {
            field(title: "手机号", text: $phone, valid: MitRegex.isValidPhone(phone))
            field(title: "邮箱",   text: $email, valid: MitRegex.isValidEmail(email))
            field(title: "密码",   text: $password, valid: MitRegex.isValidPassword(password))
            field(title: "验证码", text: $code, valid: MitRegex.isValidCode(code))
            field(title: "身份证", text: $personalId, valid: MitRegex.isValidPersonalId(personalId))
        }
    }

    private func field(title: String, text: Binding<String>, valid: Bool) -> some View {
        HStack {
            Text(title).frame(width: 60, alignment: .leading)
            TextField(title, text: text)
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
        // 任意一条失败，后续校验自动跳过，状态停留在第一个失败点。
        let maker = MitRegexMaker()
            .validateCode(code)
            .validatePhone(phone)
            .validateEmail(email)
            .validatePassword(password)
            .validatePersonalId(personalId)

        chainResultText = maker.statusString
        chainPassed = maker.isPassed
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
