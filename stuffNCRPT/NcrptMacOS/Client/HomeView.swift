//
//  HomeView.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 17.02.2023.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


struct HomeView: View {
    var body: some View {
        HStack(spacing: 0){
            VStack{
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 0){
                        HStack(spacing: 15){
                            Image("recent")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20, alignment: .center)
                                .opacity(1.0)
                            Text("Недавние")
                                .font(.system(size: 16))
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .frame(width: geometry.size.width, alignment: .leading)
                        .background(Color.init(hex: "9B9DA4").opacity(0.08))
                        HStack(spacing: 15){
                            Image("selected")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20, alignment: .center)
                                .opacity(0.3)
                            Text("Отмеченные")
                                .font(.system(size: 16))
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .frame(width: geometry.size.width, alignment: .leading)
                        HStack(spacing: 15){
                            Image("access")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20, alignment: .center)
                                .opacity(0.3)
                            Text("Мне дали доступ")
                                .font(.system(size: 16))
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .frame(width: geometry.size.width, alignment: .leading)
                        HStack(spacing: 15){
                            Image("share")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20, alignment: .center)
                                .opacity(0.3)
                            Text("Я предоставил доступ")
                                .font(.system(size: 16))
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .frame(width: geometry.size.width, alignment: .leading)
                        
                        Spacer()
                        
                        HStack(spacing: 15){
                            Image("info")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20, alignment: .center)
                                .opacity(0.7)
                            Text("Справка")
                                .font(.system(size: 16))
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .frame(width: geometry.size.width, alignment: .leading)
                        
                    }
                    .frame(width: geometry.size.width, alignment: .leading)
                    .padding(.top, 40)
                }
            }
            .frame(width: 270,
                   height:  (NSScreen.main?.frame.size.height)! * 0.65)
            .background(.white)
            VStack{
                TabsControllerSwiftUI()
            }
            .frame(width: ((NSScreen.main?.frame.size.width)! * 0.6) - 270)
            .background(.white)
        }
        .frame(width: (NSScreen.main?.frame.size.width)! * 0.6,
               height:  (NSScreen.main?.frame.size.height)! * 0.65,
               alignment: .center)
        .background(Color.white)
    }
}

