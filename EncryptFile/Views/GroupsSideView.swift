//
//  GroupsSideView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 28.10.2022.
//


import SwiftUI

struct GroupsSideView: View {
    @ObservedObject var viewModel: GroupViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(viewModel.getTitle())
                .padding(.leading)
            
            Divider()
            
            HStack {
                IconMenuView(icon: "plusIcon")
                Text("Add")
            }.padding(.leading)
            
            ForEach(self.viewModel.getTeams(), id:\.self) { group in
                if group.logo != nil {
                    HStack {
                        Image(group.logo!)
                            .resizable()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                        Text(group.name)
                    }
                } else {
                    HStack {
                        ZStack{
                            Circle()
                                .foregroundColor(group.accentColor)
                            Text(group.getFirstChar())
                        }
                        .frame(width: 48, height: 48)
                        Text(group.name)
                    }
                }
            }
            .padding(.leading)
            Spacer()
        }
    }
}

struct GroupsSideView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsSideView(viewModel: GroupViewModel())
    }
}
