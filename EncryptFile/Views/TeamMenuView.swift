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
