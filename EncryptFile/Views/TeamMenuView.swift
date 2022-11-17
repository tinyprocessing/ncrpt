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
            GroupsSideView(viewModel: viewModel)
        }
    }
}


struct GroupMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TeamMenuView(viewModel: GroupViewModel())
    }
}




