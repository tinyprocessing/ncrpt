import SwiftUI

struct IconMenuView: View {
    var icon: String
    var body: some View {
        Image(icon)
            .resizable()
            .frame(width: 48, height: 48)
            .clipShape(Circle())
    }
}
