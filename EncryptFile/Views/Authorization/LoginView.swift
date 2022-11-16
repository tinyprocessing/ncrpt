//
//  LoginView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 01.11.2022.
//

import SwiftUI
import Combine

struct LoginView: View {
    @ObservedObject private var vm = RegistrationViewModel()
    @State var isSigningIn = false
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                
                ZStack {
                    FormField(fieldName: "Login", fieldValue: $vm.email)
                        .padding(.top, 50)
                    
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(vm.isMailValid ? .green : .clear).padding(.top, 44)
                    }
                    
                }
                
                ZStack {
                    FormField(fieldName: "password", fieldValue: $vm.password, isSecure: true)
                    
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(vm.isPasswordLengthValid ? .green : .clear)
                    }
                    
                }
                
                
                Button(action: {
                    //TODO: call backend
                    print("start login")
                    if self.isSigningIn == false {
                        Network.shared.login(username: self.vm.email, password: MD5(string: self.vm.password)) { success in
                            if success {
                                self.isLoggedIn = true
                            }
                        }
                    }
                    
//                    isSigningIn = true
//                    sleep(1)
//                    isSigningIn = false
//                    isLoggedIn = true
//
                    
                }) {
                    ZStack{
                        Text(isSigningIn ? "" : "Login")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .if(vm.canLogin) { view in
                                view.background(LinearGradient(gradient: Gradient(colors: [Color(0x1d3557), Color(0xa8dadc)]), startPoint: .leading, endPoint: .trailing))
                            }
                            .if(!vm.canLogin) { view in
                                view.background(LinearGradient(gradient: Gradient(colors: [Color(0x1d3557), Color(0xa8dadc)]), startPoint: .leading, endPoint: .trailing)).opacity(0.5)
                            }
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 40)
                .disabled(!vm.canLogin)
                
                HStack {
                    Text("Don't have an account?")
                        .font(.system(.body, design: .rounded))
                        .bold()
                    
                    NavigationLink(destination: RegistrationView()) {
                        Text("Create one")
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(Color(0x457b9d))
                    }
                    .navigationTitle("")
                }.padding(.top, 50)
                
            }
            .padding()
        }
    }
    
    

}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}


struct FormField: View {
    var fieldName = ""
    @Binding var fieldValue: String
    var isSecure = false
    
    var body: some View {
        VStack {
            if isSecure {
                SecureField(fieldName, text: $fieldValue)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .padding(.horizontal)
                
            } else {
                TextField(fieldName, text: $fieldValue)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                    .textCase(.lowercase)
            }

            Divider()
                .frame(height: 1)
                .background(.gray).opacity(0.5)
                .padding(.horizontal)
            
        }
    }
}

