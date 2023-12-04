import Combine
import SwiftUI

struct LoginView: View {
    @ObservedObject private var vm = RegistrationViewModel()
    @State var isSigningIn = false

    @ObservedObject var api = NCRPTWatchSDK.shared

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image("NCRPTBlue")
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
                    // TODO: call backend
                    log.debug(type: "LoginView", object: "Start authorize user \(self.vm.email)")
                    self.api.ui = .loading
                    if self.isSigningIn == false {
                        Network.shared.login(username: self.vm.email.lowercased(), password: MD5(string: self.vm.password)) { success in
                            if success {
                                log.debug(type: "LoginView", object: "Success authorize user \(self.vm.email)")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.api.ui = .pinCreate
                                }
                            } else {
                                log.debug(type: "LoginView", object: "🛑 Error authorize user \(self.vm.email)")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.api.ui = .auth
                                    Settings.shared.alert(title: "Error", message: "Service failed to authorize", buttonName: "Repeat")
                                }
                            }
                        }
                    }

                }) {
                    ZStack {
                        Text(isSigningIn ? "" : "Login")
                            .modifier(NCRPTTextMedium(size: 16))
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .if(vm.canLogin) { view in
                                view.background(Color(hex: "4378DB"))
                            }
                            .if(!vm.canLogin) { view in
                                view.background(Color(hex: "4378DB")).opacity(0.5)
                            }
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 40)
                .disabled(!vm.canLogin)

                HStack {
                    Text("Don't have an account?")
                        .modifier(NCRPTTextMedium(size: 16))
                        .bold()

                    NavigationLink(destination: RegistrationView()) {
                        Text("Create one")
                            .modifier(NCRPTTextMedium(size: 16))
                            .bold()
                            .foregroundColor(Color(hex: "4378DB"))
                    }
                    .navigationTitle("")
                }.padding(.top, 50)
            }
            .padding()
        }
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
                    .modifier(NCRPTTextMedium(size: 20))
                    .padding(.horizontal)

            } else {
                TextField(fieldName, text: $fieldValue)
                    .modifier(NCRPTTextMedium(size: 20))
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
