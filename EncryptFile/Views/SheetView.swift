import PDFKit
import SwiftUI

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var content = ProtectViewModel.shared

    @State var currentDate = Date.now
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State var opacity = 0.01
    var body: some View {
        ZStack {
            if !content.chosenFiles.isEmpty {
                if isPDFFile() {
                    let pdfDoc = PDFDocument(url: (content.chosenFiles.first?.url!)!)!
                    PDFKitView(show: pdfDoc)
                        .hiddenFromSystemSnaphot(when: true)
                        .opacity(self.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    self.opacity = 1.0
                                }
                            }
                        }
                } else {
                    FileWebView(url: (content.chosenFiles.first?.url!)!)
                        .hiddenFromSystemSnaphot(when: true)
                        .opacity(self.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    self.opacity = 1.0
                                }
                            }
                        }
                }
            } else {
                VStack {
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                        .foregroundColor(.secondary)

                    Text("Decrypting file")
                        .modifier(NCRPTTextMedium(size: 16))
                }
            }
        }
        .navigationTitle("viewer")
        .navigationBarTitleDisplayMode(.inline)

        .navigationBarItems(
            leading:
            EmptyView(),

            trailing:
            NavigationLink(destination: RightsView(content: self.content), label: {
                HStack {
                    Image(systemName: "list.clipboard")
                        .foregroundColor(.black)
                }.clipShape(Rectangle())
            })
        )
    }

    private func isPDFFile() -> Bool {
        return content.chosenFiles.first?.ext == "pdf"
    }
}
