//
//  RightsView.swift
//  EncryptFile
//
//  Created by Michael Safir on 23.12.2022.
//

import SwiftUI

struct RightsView: View {
    @ObservedObject var content : ProtectViewModel

    var body: some View {
        VStack(alignment: .leading){
            if let rights = self.content.rights {
                if !rights.users.isEmpty {
                    ScrollView(.vertical, showsIndicators: false){
                        VStack(alignment: .leading, spacing: 5){
                            ForEach(Array(zip(rights.users, rights.rights)), id: \.0) { item in
                                VStack{
                                    HStack{
                                        VStack(alignment: .leading, spacing: 5){
                                            Text(item.0)
                                                .modifier(NCRPTTextMedium(size: 16))
                                            Text(item.1.lowercased().replacingOccurrences(of: ",", with: ", "))
                                                .modifier(NCRPTTextMedium(size: 14))
                                                .opacity(0.7)
                                        }
                                        Spacer()
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                }else{
                    Spacer()
                    HStack{
                        Spacer()
                        Text("no rights avalible")
                            .modifier(NCRPTTextSemibold(size: 18))
                            .foregroundColor(Color.init(hex: "21205A"))
                        Spacer()
                    }
                    Spacer()
                }
            }else{
                Spacer()
                HStack{
                    Spacer()
                    Text("no rights avalible")
                        .modifier(NCRPTTextSemibold(size: 18))
                        .foregroundColor(Color.init(hex: "21205A"))
                    Spacer()
                }
                Spacer()
            }
        }
        .padding(.horizontal)
        .navigationTitle("rights")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            
        }
    }
}

