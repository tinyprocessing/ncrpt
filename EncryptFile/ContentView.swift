//
//  ContentView.swift
//  EncryptFile
//
//  Created by Michael Safir on 25.10.2022.
//

import SwiftUI
import UniformTypeIdentifiers
import QuickLook
import QuartzCore

extension UIView {
    func preventScreenshot() {
        guard superview != nil else {
            for subview in subviews {
                subview.preventScreenshot()
            }
            return
        }

        let guardTextField = UITextField()
        guardTextField.backgroundColor = .red
        guardTextField.translatesAutoresizingMaskIntoConstraints = false
        guardTextField.tag = Int.max
        guardTextField.isSecureTextEntry = true

        addSubview(guardTextField)
        guardTextField.isUserInteractionEnabled = false
        sendSubviewToBack(guardTextField)

        layer.superlayer?.addSublayer(guardTextField.layer)
        guardTextField.layer.sublayers?.first?.addSublayer(layer)

        guardTextField.centerYAnchor.constraint(
            equalTo: self.centerYAnchor
        ).isActive = true

        guardTextField.centerXAnchor.constraint(
            equalTo: self.centerXAnchor
        ).isActive = true
    }
}

struct PreviewController: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            controller.view.subviews.forEach { view in
                view.preventScreenshot()
                print(view)
            }
        }
        
        
        let view = UIView()
        view.backgroundColor = .red
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        
        view.preventScreenshot()
//        controller.view.addSubview(view)
        controller.view.preventScreenshot()
        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func updateUIViewController(
        _ uiViewController: QLPreviewController, context: Context) {}
    
    class Coordinator: QLPreviewControllerDataSource {
        let parent: PreviewController
        
        init(parent: PreviewController) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(
            in controller: QLPreviewController
        ) -> Int {
            return 1
        }
        
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            return parent.url as NSURL
        }
        
    }
}





struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var content : URL?
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    self.dismiss()
                }, label: {
                    Text("Close")
                        .foregroundColor(Color.black)
                })
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 15)
            PreviewController(url: self.content!)
        }
    }
}

struct ContentView: View {
    
    @State private var showingContent = false
    @State private var isShowMenu = false
    @ObservedObject var localFiles: LocalFileEngine = LocalFileEngine()
    @State private var document: FileDocumentStruct = FileDocumentStruct()
    @State private var isImporting: Bool = false
    @State private var isImportingEncrypt: Bool = false
    @State private var isImportingDecrypt: Bool = false
    @State var content : URL? = nil
    
    func getAtualTypes() -> [UTType]{
        if self.isImportingEncrypt {
            return [.pdf, .docx, .png, .jpg, .jpeg, .zip, .image, .tiff, .gif, .pptx, .xlsx, .plainText]
        }
        if self.isImportingDecrypt {
            return [.ncrpt, .zip]
        }
        return []
    }
    
    var body: some View {
        NavigationView{
            ZStack {
                if isShowMenu {
                    SideMenu(isShowMenu: $isShowMenu)
                }
                ZStack {
                    Color(.white)
                    
                    VStack{
                        VStack{
                            ScrollView(.vertical, showsIndicators: false){
                                ForEach(self.localFiles.files, id:\.self) { file in
                                    HStack(spacing: 15){
                                        HStack(spacing: 5){
                                            Text("\(file.name)")
                                                .onTapGesture {
                                                    if file.url != nil {
                                                        DispatchQueue.global(qos: .userInitiated).async {
                                                            let polygone = Polygone()
                                                            let result = polygone.decryptFile(file.url!)
                                                            self.content = result
                                                            DispatchQueue.main.async {
                                                                showingContent.toggle()
                                                            }
                                                        }
                                                    }
                                                }
                                        }
                                        Spacer()
                                        
                                        Button(action: {
                                            share(items: [file.url!])
                                        }, label: {
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.system(size: 18))
                                                .foregroundColor(Color.black)
                                        })
                                        
                                        Button(action: {
                                            do {
                                                try FileManager.default.removeItem(atPath: (file.url?.path().removingPercentEncoding)!)
                                                self.localFiles.getLocalFiles()
                                            } catch {
                                                print("Could not delete file, probably read-only filesystem")
                                            }
                                        }, label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 18))
                                                .foregroundColor(Color.red)
                                        })
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 10)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .frame(height: 200)
                        }
                        Spacer()
                        Button(action: {
//                            localFiles.getLocalFiles()
//                            isImportingEncrypt = false
//                            isImportingDecrypt = true
//                            isImporting = true
                            let polygone = Polygone()
                            polygone.testCertification()
                        }, label: {
                            Text("Open File")
                                .padding(.horizontal, 55)
                                .padding(.vertical, 10)
                                .background(Color.black)
                                .cornerRadius(8.0)
                                .foregroundColor(Color.white)
                        })
                    }
                    .fileImporter(
                        isPresented: $isImporting,
                        allowedContentTypes: self.getAtualTypes(),
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            self.document.url = selectedFile
                            let one = selectedFile.startAccessingSecurityScopedResource()
                            if self.isImportingEncrypt {
                                let polygone = Polygone()
                                polygone.encryptFile(self.document.url!)
                                localFiles.getLocalFiles()
                            }
                            
                            if self.isImportingDecrypt {
                                let polygone = Polygone()
                                let result = polygone.decryptFile(self.document.url!)
                                self.content = result
                                showingContent.toggle()
                            }
                        } catch {
                            // Handle failure.
                        }
                    }
                    .sheet(isPresented: $showingContent) {
                        SheetView(content: self.$content)
                    }
                    .onAppear{
                        self.localFiles.getLocalFiles()
                    }
                }
                .navigationBarItems(
                    leading: Button(action: {
                        withAnimation(.spring()) {
                            isShowMenu.toggle()
                        }
                        
                    }, label: {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.black)
                    }),
                    trailing: Button(action: {
                        //                    let polygone = Polygone()
                        //                    polygone.fileEncyptionTest()
                        isImportingDecrypt = false
                        isImportingEncrypt = true
                        isImporting = true
                    }, label: {
                        Image(systemName: "lock")
                            .foregroundColor(.black)
                    })
                )
                .cornerRadius(isShowMenu ? 20 : 10)
                .offset(x: isShowMenu ? 300 : 0, y: isShowMenu ? 44 : 0)
                //                .scaleEffect(isShowMenu ? 0.8 : 1)
                .navigationTitle("ncrpt.io")
                .navigationBarTitleDisplayMode(.inline)
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

@discardableResult
func share(
    items: [Any],
    excludedActivityTypes: [UIActivity.ActivityType]? = nil
) -> Bool {
    guard let source = UIApplication.shared.windows.last?.rootViewController else {
        return false
    }
    let vc = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil
    )
    vc.excludedActivityTypes = excludedActivityTypes
    vc.popoverPresentationController?.sourceView = source.view
    source.present(vc, animated: true)
    return true
}

