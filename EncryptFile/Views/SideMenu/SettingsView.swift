import Combine
import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance")
    var appearance: Appearance = .light

    @State var email = ""
    @State var server = "https://security.ncrpt.io"

    @ObservedObject var api = NCRPTWatchSDK.shared

    @State private var rsa = true
    @State private var trustNetwork = true
    @State private var crashReporting = true
    @State private var compress = true
    @State private var faceID = true

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 15) {
//                        Text("UI")
//                            .modifier(NCRPTTextSemibold(size: 18))
//                            .foregroundColor(Color.init(hex: "21205A"))
//                        Picker("Pick", selection: $appearance) {
//                            ForEach(Appearance.allCases) { appearance in
//                                Text(appearance.name).tag(appearance)
//                            }
//                        }
//                        .pickerStyle(SegmentedPickerStyle())
//                        .padding(.bottom, 10)

                        HStack {
                            Text("General")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color(hex: "21205A"))
                            Spacer()
                        }
                        HStack {
                            Text("Account")
                                .modifier(NCRPTTextMedium(size: 16))
                            Spacer()
                            Text(self.email)
                                .modifier(NCRPTTextMedium(size: 14))
                                .padding(.leading)
                                .opacity(0.7)
                        }

                        NavigationLink(destination: CertificationView(), label: {
                            HStack {
                                Text("Certificates")
                                    .modifier(NCRPTTextMedium(size: 16))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(.leading)
                                    .opacity(0.7)
                            }.clipShape(Rectangle())
                        })

                        HStack {
                            Text("Share Logs")
                                .modifier(NCRPTTextMedium(size: 16))
                            Spacer()

                            Button(action: {
                                Settings.shared.shareLogs()
                            }, label: {
                                Image(systemName: "square.and.arrow.up")
                                    .padding(.leading)
                                    .opacity(0.7)
                                    .clipShape(Rectangle())
                            })
                        }

//                        HStack{
//                            Text("Compress Files")
//                                .modifier(NCRPTTextMedium(size: 16))
//                            Spacer()
//                            Toggle("", isOn: $compress)
//                                .offset(x: -5)
//                                .tint(Color.init(hex: "21205A"))
//                                .onChange(of: self.compress, perform: { newValue in
//                                    print(newValue)
//                                    let defaults = UserDefaults.standard
//                                    defaults.set(newValue, forKey: UserDefaults.Keys.SettingsCompress.rawValue)
//                                })
//                        }
                    }
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Security")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color(hex: "21205A"))
                            Spacer()
                        }
                        HStack {
                            Text("Server")
                                .modifier(NCRPTTextMedium(size: 16))
                            Spacer()
                            Text(self.server)
                                .modifier(NCRPTTextMedium(size: 14))
                                .padding(.leading)
                                .opacity(0.7)
                        }
//                        HStack{
//                            VStack(alignment: .leading){
//                                Text("RSA Connection")
//                                    .modifier(NCRPTTextMedium(size: 16))
//                                Text("This setting helps to protect the connection between the server and the client with its own ncrpt
//                                protocol")
//                                    .modifier(NCRPTTextMedium(size: 14))
//                                    .opacity(0.5)
//                            }
//                            Spacer()
//                            Toggle("", isOn: $rsa)
//                                .offset(x: -5)
//                                .tint(Color.init(hex: "21205A"))
//                                .onChange(of: self.rsa, perform: { newValue in
//                                    print(newValue)
//                                    let defaults = UserDefaults.standard
//                                    defaults.set(newValue, forKey: UserDefaults.Keys.SettingsRSA.rawValue)
//                                })
//                        }
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Trust connection")
                                    .modifier(NCRPTTextMedium(size: 16))
                                Text(
                                    "This setting helps to identify untrusted networks on your device and prevent the app from being used to safeguard your data"
                                )
                                .modifier(NCRPTTextMedium(size: 14))
                                .opacity(0.5)
                            }
                            Spacer()
                            Toggle("", isOn: $trustNetwork)
                                .offset(x: -5)
                                .tint(Color(hex: "21205A"))
                                .onChange(of: self.trustNetwork, perform: { newValue in
                                    print(newValue)
                                    let defaults = UserDefaults.standard
                                    defaults.set(newValue, forKey: UserDefaults.Keys.SettingsTrust.rawValue)
                                })
                        }
                        HStack {
                            Text("Crash Reporting")
                                .modifier(NCRPTTextMedium(size: 16))
                            Spacer()
                            Toggle("", isOn: $crashReporting)
                                .offset(x: -5)
                                .tint(Color(hex: "21205A"))
                                .onChange(of: self.crashReporting, perform: { newValue in
                                    print(newValue)
                                    let defaults = UserDefaults.standard
                                    defaults.set(newValue, forKey: UserDefaults.Keys.SettingsCrashReporting.rawValue)
                                })
                        }

                        HStack {
                            Text("Face ID")
                                .modifier(NCRPTTextMedium(size: 16))
                            Spacer()
                            Toggle("", isOn: $faceID)
                                .offset(x: -5)
                                .tint(Color(hex: "21205A"))
                                .onChange(of: self.faceID, perform: { newValue in
                                    print(newValue)
                                    let defaults = UserDefaults.standard
                                    defaults.set(newValue, forKey: UserDefaults.Keys.SettingsFaceID.rawValue)
                                })
                        }

//                        NavigationLink(destination: PinEntryView(), label: {
//                            HStack{
//                                Text("PIN & FaceID")
//                                    .modifier(NCRPTTextMedium(size: 16))
//                                Spacer()
//                                Image(systemName: "chevron.right")
//                                    .padding(.leading)
//                                    .opacity(0.7)
//                            }.clipShape(Rectangle())
//                        }).simultaneousGesture(TapGesture().onEnded{
//                            self.api.ui = .pinCreate
//                        })
                    }
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Network")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color(hex: "21205A"))
                            Spacer()
                        }
                        NavigationLink(destination: NetworkView(), label: {
                            HStack {
                                Text("System Information")
                                    .modifier(NCRPTTextMedium(size: 16))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(.leading)
                                    .opacity(0.7)
                            }.clipShape(Rectangle())
                        })
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle("settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let defaults = UserDefaults.standard
            self.faceID = defaults.bool(forKey: UserDefaults.Keys.SettingsFaceID.rawValue)
            self.trustNetwork = defaults.bool(forKey: UserDefaults.Keys.SettingsTrust.rawValue)
            self.crashReporting = defaults.bool(forKey: UserDefaults.Keys.SettingsCrashReporting.rawValue)
            self.rsa = defaults.bool(forKey: UserDefaults.Keys.SettingsRSA.rawValue)
            self.compress = defaults.bool(forKey: UserDefaults.Keys.SettingsCompress.rawValue)
            self.server = defaults.string(forKey: UserDefaults.Keys.SettingsServer.rawValue) ?? Settings.shared.server
            DispatchQueue.global(qos: .userInitiated).async {
                let certification = Certification()
                certification.getCertificate()
                DispatchQueue.main.async {
                    self.email = certification.certificate.email ?? ""
                }
            }
        }
    }
}
