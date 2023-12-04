import SwiftUI

struct SideMenu: View {
    @Binding var isShowMenu: Bool

    @StateObject var viewModel = GroupViewModel()
    @ObservedObject var pvm: ProtectViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .leading) {
                Color(hex: "F2F3F4")
                    .ignoresSafeArea()

                TeamMenuView(viewModel: viewModel, pvm: pvm)
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
