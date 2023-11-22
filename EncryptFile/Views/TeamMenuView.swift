//
//  GroupMenuView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 28.10.2022.
//

import SwiftUI

struct TeamMenuView: View {
    @ObservedObject var viewModel: GroupViewModel
    @ObservedObject var pvm: ProtectViewModel

    var body: some View {
        HStack {
            GroupsSideView(viewModel: viewModel, pvm: pvm)
        }
    }
}

struct GroupMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TeamMenuView(viewModel: GroupViewModel(), pvm: ProtectViewModel())
    }
}
