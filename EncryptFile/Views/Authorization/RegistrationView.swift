//
//  RegistrationView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 01.11.2022.
//

import SwiftUI

struct RegistrationView: View {
    @ObservedObject private var vm = RegistrationViewModel()
    @ObservedObject var api: NCRPTWatchSDK = NCRPTWatchSDK.shared
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            Text("Create an\naccount")
                .multilineTextAlignment(.center)
                .modifier(NCRPTTextSemibold(size: 25))
                .bold()
                .padding(.bottom, 70)

            ZStack {
                FormField(fieldName: "Login", fieldValue: $vm.email)

                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(
                            vm.isMailValid
                                ? .green
                                : .clear
                        )
                }
            }

            Spacer().frame(height: 40)

            FormField(fieldName: "Password", fieldValue: $vm.password, isSecure: true)
            VStack(spacing: 10) {
                RequirementText(
                    iconName: vm.isPasswordLengthValid
                        ? "checkmark.circle"
                        : "xmark.square",
                    iconColor: vm.isPasswordLengthValid
                        ? .green : .secondary,
                    text: "A minimum of 8 characters",
                    isStrikeThrough: vm.isPasswordLengthValid
                )

                RequirementText(
                    iconName: vm.isPasswordCapitalLetter
                        ? "checkmark.circle"
                        : "xmark.square",
                    iconColor: vm.isPasswordCapitalLetter
                        ? .green : .secondary,
                    text: "One uppercase letter",
                    isStrikeThrough: vm.isPasswordCapitalLetter
                )
            }
            .padding()

            Spacer().frame(height: 40)

            FormField(
                fieldName: "Confirm Password",
                fieldValue: $vm.passwordConfirm,
                isSecure: true
            )

            RequirementText(
                iconName: vm.isPasswordConfirmValid
                    ? "checkmark.circle" : "xmark.square",
                iconColor: vm.isPasswordConfirmValid ? .green : .secondary,
                text: "Your confirm password should be the same as password",
                isStrikeThrough: vm.isPasswordConfirmValid
            )
            .padding()
            .padding(.bottom, 50)

            Button(action: {
                Network.shared.registration(
                    username: self.vm.email.lowercased(),
                    password: MD5(string: self.vm.password)
                ) { success in
                    if success {
                        log.debug(
                            type:
                                "RegistrationView",
                            object:
                                "Success registration user \(self.vm.email)"
                        )
                        DispatchQueue.main.asyncAfter(
                            deadline: .now()
                                + 0.5,
                            execute: {
                                presentationMode
                                    .wrappedValue
                                    .dismiss()
                            }
                        )
                    }
                    else {
                        log.debug(
                            type:
                                "RegistrationView",
                            object:
                                "🛑 Error registration user \(self.vm.email)"
                        )
                        DispatchQueue.main.asyncAfter(
                            deadline: .now()
                                + 0.5,
                            execute: {
                                self.api
                                    .ui =
                                    .auth
                                Settings
                                    .shared
                                    .alert(
                                        title:
                                            "Error",
                                        message:
                                            "Service failed to authorize",
                                        buttonName:
                                            "Repeat"
                                    )
                            }
                        )
                    }
                }
            }) {
                Text("Registry")
                    .modifier(NCRPTTextMedium(size: 16))
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .if(vm.canRegister) { view in
                        view.background(
                            Color.init(
                                hex:
                                    "4378DB"
                            )
                        )
                    }
                    .if(!vm.canRegister) { view in
                        view.background(
                            Color.init(
                                hex:
                                    "4378DB"
                            )
                        ).opacity(0.5)
                    }
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(!vm.canRegister)

        }
        .padding()
        .ignoresSafeArea(.keyboard)
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}

struct RequirementText: View {

    var iconName = "xmark.square"
    var iconColor = Color(red: 251 / 255, green: 128 / 255, blue: 128 / 255)

    var text = ""
    var isStrikeThrough = false

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
            Text(text)
                .modifier(NCRPTTextMedium(size: 16))
                .foregroundColor(.secondary)
                .strikethrough(isStrikeThrough)
            Spacer()
        }
    }
}
