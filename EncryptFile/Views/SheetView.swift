//
//  SheetView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 02.01.2023.
//

import SwiftUI

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var content : ProtectViewModel = ProtectViewModel.shared
    
    @State var currentDate = Date.now
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    
    @State var opacity : Double = 0.01
    var body: some View {
        ZStack{
            if self.content.chosenFiles.count > 0 {
//                PreviewController(url: (self.content.chosenFiles.first?.url!)!)
                FileWebView(url: (self.content.chosenFiles.first?.url!)!)
                    .hiddenFromSystemSnaphot(when: true)

                    .opacity(self.opacity)
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            withAnimation{
                                self.opacity = 1.0
                            }
                        })
                    }
            }else{
                VStack{
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                        .foregroundColor(.secondary)
                    
                    Text("Decrypting file")
                        .modifier(NCRPTTextMedium(size: 16))
                }
            }
        }
        .navigationTitle("viewer")
        .navigationBarTitleDisplayMode(.inline)
        
        .navigationBarItems(
            leading:
                EmptyView()
            ,
            trailing:
                NavigationLink(destination: RightsView(content: self.content), label: {
                    HStack{
                        Image(systemName: "list.clipboard")
                            .foregroundColor(.black)
                    }.clipShape(Rectangle())
                })
        )
    }
}