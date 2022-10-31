//
//  GroupMenuView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 28.10.2022.
//

import SwiftUI

struct TeamMenuView: View {
    @ObservedObject var viewModel: GroupViewModel
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                ForEach(self.viewModel.groupData, id:\.self) { group in
                    configureLogo(group)
                        .onTapGesture {
                            viewModel.selectedGroup = group.id
                            viewModel.isShowSettings = false
                            viewModel.isCreateNewGroup = false
                        }
                }
                //plus icon
                if viewModel.isCreateNewGroup {
                    HStack {
                        configureCapsule()
                        IconMenuView(icon: "plusIcon")
                    }
                    .onTapGesture {
                        viewModel.getNewGroupId()
                    }
                } else {
                    IconMenuView(icon: "plusIcon")
                        .padding(.leading, 14)
                        .onTapGesture {
                            viewModel.getNewGroupId()
                        }
                }
                Spacer()
                //setting icon
                if viewModel.isShowSettings {
                    HStack {
                        Capsule()
                            .fill(.gray)
                            .frame(width: 6, height: 37)
                        IconMenuView(icon: "settingIcon")
                    }
                    .onTapGesture {
                        viewModel.showSettings()
                    }
                } else {
                    IconMenuView(icon: "settingIcon").padding(.leading, 14)
                        .onTapGesture {
                            viewModel.showSettings()
                        }
                }
            }
            .frame(width: 82)
            GroupsSideView(viewModel: viewModel)
        }
    }
    

    
    fileprivate func configureLogo(_ group: GroupData) -> some View {
        if group.logo != nil {
            return AnyView(
                HStack{
                    if group.id == viewModel.selectedGroup {
                        configureCapsule()
                    } else {
                        Spacer().frame(width: 14)
                    }
                    Image(group.logo!)
                        .resizable()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                }
            )
        } else {
            return AnyView(
                HStack{
                    if group.id == viewModel.selectedGroup {
                        configureCapsule()
                    } else {
                        Spacer().frame(width: 14)
                    }
                    ZStack{
                        Circle()
                            .foregroundColor(group.accentColor)
                        Text(group.getFirstChar())
                    }
                    .frame(width: 48, height: 48)
                }
            )
        }
    }
    
    fileprivate func configureCapsule() -> some View {
        return AnyView(Capsule()
            .fill(.gray)
            .frame(width: 6, height: 37))
    }
    
}


struct GroupMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TeamMenuView(viewModel: GroupViewModel())
    }
}




