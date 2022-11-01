//
//  RegistrationView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 01.11.2022.
//

import SwiftUI

struct RegistrationView: View {
    @ObservedObject private var vm = RegistrationViewModel()
    
    var body: some View {
        VStack {
            Text("Create an \naccount")
                .multilineTextAlignment(.center)
                .font(.system(.largeTitle, design: .rounded))
                .bold()
                .padding(.bottom, 70)
            
            ZStack {
                FormField(fieldName: "Email", fieldValue: $vm.email)
                
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(vm.isMailValid ? .green : .clear)
                }
            }
            
            Spacer().frame(height: 40)

            
            FormField(fieldName: "Password", fieldValue: $vm.password, isSecure: true)
            VStack {
                RequirementText(iconName: vm.isPasswordLengthValid ? "checkmark.circle":"xmark.square",
                                iconColor: vm.isPasswordLengthValid ? .green : .secondary,
                                text: "A minimum of 8 characters", isStrikeThrough: vm.isPasswordLengthValid)
                
                RequirementText(iconName: vm.isPasswordCapitalLetter ? "checkmark.circle":"xmark.square",
                                iconColor: vm.isPasswordCapitalLetter ? .green : .secondary,
                                text: "One uppercase letter",
                                isStrikeThrough: vm.isPasswordCapitalLetter)
            }
            .padding()
            
            Spacer().frame(height: 40)

            FormField(fieldName: "Confirm Password", fieldValue: $vm.passwordConfirm, isSecure: true)
            
            RequirementText(iconName: vm.isPasswordCapitalLetter ?             "checkmark.circle":"xmark.square",
                            iconColor: vm.isPasswordConfirmValid ? .green : .secondary,
                            text: "Your confirm password should be the same as password",
                            isStrikeThrough: vm.isPasswordConfirmValid)
                .padding()
                .padding(.bottom, 50)
            
            Button(action: {
                // Call backend
            }) {
                Text("Registry")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .if(vm.canRegister) { view in
                        view.background(LinearGradient(gradient: Gradient(colors: [Color(0x1d3557), Color(0xa8dadc)]), startPoint: .leading, endPoint: .trailing))
                    }
                    .if(!vm.canRegister) { view in
                        view.background(LinearGradient(gradient: Gradient(colors: [Color(0x1d3557), Color(0xa8dadc)]), startPoint: .leading, endPoint: .trailing)).opacity(0.5)
                    }
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(!vm.canRegister)
            
        }
        .padding()
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}

struct RequirementText: View {
    
    var iconName = "xmark.square"
    var iconColor = Color(red: 251/255, green: 128/255, blue: 128/255)
    
    var text = ""
    var isStrikeThrough = false
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.secondary)
                .strikethrough(isStrikeThrough)
            Spacer()
        }
    }
}
