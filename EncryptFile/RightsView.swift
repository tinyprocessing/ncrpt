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
                VStack{
                    HStack{
                        VStack(alignment: .leading, spacing: 5){
                            Text(rights.owner)
                                .modifier(NCRPTTextMedium(size: 16))
                            Text("OWNER")
                                .modifier(NCRPTTextMedium(size: 12))
                                .padding(2.5)
                                .background(.red.opacity(0.2))
                                .cornerRadius(5)
                                .foregroundColor(.red)
                        }
                        Spacer()
                    }
                    Divider()
                }
            }
            
            if let rights = self.content.rights {
                if !rights.users.isEmpty {
                    ScrollView(.vertical, showsIndicators: false){
                        VStack(alignment: .leading, spacing: 5){
                            let value = Array(zip(rights.id, zip(rights.users, rights.rights)))
                            ForEach(value, id: \.0) { (id, arg1) in
                                let (userValue, rightValue) = arg1
                                VStack{
                                    HStack{
                                        VStack(alignment: .leading, spacing: 5){
                                            Text(userValue)
                                                .modifier(NCRPTTextMedium(size: 16))
                                            Text(rightValue.lowercased().replacingOccurrences(of: ",", with: ", "))
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

