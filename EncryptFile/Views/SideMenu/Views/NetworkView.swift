//
//  NetworkView.swift
//  EncryptFile
//
//  Created by Michael Safir on 08.01.2023.
//

import SwiftUI

struct NetworkView: View {
    @State var interfaces : [Interface] = []
    var body: some View {
        VStack(alignment: .leading){
            if !self.interfaces.isEmpty {
                ScrollView(.vertical, showsIndicators: false){
                    VStack(alignment: .leading, spacing: 5){
                        ForEach(self.interfaces, id:\.self) { item in
                            HStack{
                                VStack(alignment: .leading, spacing: 5){
                                    Text(item.name)
                                        .modifier(NCRPTTextSemibold(size: 18))
                                        .foregroundColor(Color.init(hex: "21205A"))
                                    Text(item.description)
                                        .modifier(NCRPTTextMedium(size: 16))
                                }
                                Spacer()
                                Text(item.address ?? "-")
                                    .modifier(NCRPTTextMedium(size: 14))
                                    .padding(.leading)
                                    .opacity(0.7)
                            }
                            Divider()
                        }
                    }.padding(.horizontal)
                    Spacer()
                }
            }else{
                VStack{
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                        .foregroundColor(.secondary)
                    
                    Text("loading")
                        .modifier(NCRPTTextMedium(size: 16))
                }
            }
        }
        .navigationTitle("network")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            self.interfaces = Interface.allInterfaces()
        }
    }
}
