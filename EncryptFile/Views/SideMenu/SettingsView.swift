//
//  SettingsView.swift
//  EncryptFile
//
//  Created by Michael Safir on 23.12.2022.
//

import SwiftUI

struct SettingsView: View {
    @State var email : String = ""
    @State var server : String = "https://security.ncrpt.io"
    
    @State private var rsa = true
    @State private var trustNetwork = true
    @State private var crashReporting = true
    @State private var compress = true

    var body: some View {
        VStack(alignment: .leading){
            ScrollView(.vertical, showsIndicators: false){
                VStack(alignment: .leading, spacing: 15){
                    VStack(alignment: .leading, spacing: 15){
                        HStack{
                            Text("General")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color.init(hex: "21205A"))
                            Spacer()
                        }
                        HStack{
                            Text("Account")
                                .modifier(NCRPTTextMedium(size: 16))
                            Spacer()
                            Text(self.email)
                                .modifier(NCRPTTextMedium(size: 14))
                                .padding(.leading)
                                .opacity(0.7)
                        }
                        
                        NavigationLink(destination: Text("Certificates"), label: {
                            HStack{
                                Text("Certificates")
                                    .modifier(NCRPTTextMedium(size: 16))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(.leading)
                                    .opacity(0.7)
                            }.clipShape(Rectangle())
                        })
                        
                        NavigationLink(destination: Text("Certificates"), label: {
                            HStack{
                                Text("Logs")
                                    .modifier(NCRPTTextMedium(size: 16))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(.leading)
                                    .opacity(0.7)
                            }.clipShape(Rectangle())
                        })
                        
                        HStack{
                            Text("Compress Files")
                                .modifier(NCRPTTextMedium(size: 16))
                            Spacer()
                            Toggle("", isOn: $compress)
                                .offset(x: -5)
                                .tint(Color.init(hex: "21205A"))
                        }
                        
                    }
                    VStack(alignment: .leading, spacing: 15){
                        HStack{
                            Text("Security")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color.init(hex: "21205A"))
                            Spacer()
                        }
                        HStack{
                            Text("Server")
                                .modifier(NCRPTTextMedium(size: 16))
                            Spacer()
                            Text(self.server)
                                .modifier(NCRPTTextMedium(size: 14))
                                .padding(.leading)
                                .opacity(0.7)
                        }
                        HStack{
                            VStack(alignment: .leading){
                                Text("RSA Connection")
                                    .modifier(NCRPTTextMedium(size: 16))
                                Text("This setting helps to protect the connection between the server and the client with its own ncrpt protocol")
                                    .modifier(NCRPTTextMedium(size: 14))
                                    .opacity(0.5)
                            }
                            Spacer()
                            Toggle("", isOn: $rsa)
                                .offset(x: -5)
                                .tint(Color.init(hex: "21205A"))
                        }
                        HStack{
                            VStack(alignment: .leading){
                                Text("Trust connection")
                                    .modifier(NCRPTTextMedium(size: 16))
                                Text("This setting helps to identify untrusted networks on your device and prevent the app from being used to safeguard your data")
                                    .modifier(NCRPTTextMedium(size: 14))
                                    .opacity(0.5)
                            }
                            Spacer()
                            Toggle("", isOn: $trustNetwork)
                                .offset(x: -5)
                                .tint(Color.init(hex: "21205A"))
                                
                        }
                        HStack{
                            Text("Crash Reporting")
                                .modifier(NCRPTTextMedium(size: 16))
                            Spacer()
                            Toggle("", isOn: $crashReporting)
                                .offset(x: -5)
                                .tint(Color.init(hex: "21205A"))
                        }
                        NavigationLink(destination: Text("PIN"), label: {
                            HStack{
                                Text("PIN & FaceID")
                                    .modifier(NCRPTTextMedium(size: 16))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(.leading)
                                    .opacity(0.7)
                            }.clipShape(Rectangle())
                        })
                    }
                    VStack(alignment: .leading, spacing: 15){
                        HStack{
                            Text("Network")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color.init(hex: "21205A"))
                            Spacer()
                        }
                        NavigationLink(destination: Text("Network"), label: {
                            HStack{
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
        .onAppear{
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


