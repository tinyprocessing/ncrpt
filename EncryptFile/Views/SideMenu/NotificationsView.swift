//
//  NotificationsView.swift
//  EncryptFile
//
//  Created by Michael Safir on 17.12.2022.
//

import SwiftUI

struct NotificationsView: View {
    @State var notifications : [APINotifications.Notification] = []
    var body: some View {
        VStack(alignment: .leading){
            if !self.notifications.isEmpty {
                ScrollView(.vertical, showsIndicators: false){
                    VStack(alignment: .leading, spacing: 5){
                        ForEach(self.notifications, id:\.self) { item in
                            HStack{
                                VStack(alignment: .leading, spacing: 5){
                                    Text(item.title)
                                        .modifier(NCRPTTextSemibold(size: 18))
                                        .foregroundColor(Color.init(hex: "21205A"))
                                    Text(item.text)
                                        .modifier(NCRPTTextMedium(size: 16))
                                }
                                Spacer()
                                Text(item.time)
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
        .navigationTitle("notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            let api = APINotifications()
            api.getAll { all, success in
                if success {
                    self.notifications = all
                }
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
