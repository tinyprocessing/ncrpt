//
//  SideMenu.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 28.10.2022.
//

import SwiftUI

struct SideMenu: View {
    @Binding var isShowMenu: Bool
    
    @StateObject var viewModel = GroupViewModel()
    @ObservedObject var pvm: ProtectViewModel
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .leading) {
                Color.init(hex: "4378DB")
                    .ignoresSafeArea()
                
                TeamMenuView(viewModel: viewModel, pvm: pvm)
                    .navigationBarHidden(true)
            }
            
            Button {
                withAnimation(.spring()) {
                    isShowMenu.toggle()
                }
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(.trailing, 20)
                    .padding(.top, 10)
            }
        }
  
    }
}

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu(isShowMenu: .constant(true), viewModel: GroupViewModel(), pvm: ProtectViewModel())
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
