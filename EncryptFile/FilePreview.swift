//
//  FilePreview.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 17.11.2022.
//

import Foundation
import SwiftUI
import QuartzCore
import UIKit
import UniformTypeIdentifiers
import QuickLook

extension UIView {
    func preventScreenshot() {
        guard superview != nil else {
            for subview in subviews {
                subview.preventScreenshot()
            }
            return
        }
        
        let guardTextField = UITextField()
        guardTextField.backgroundColor = .white
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

class QLPreviewControllerNew: QLPreviewController {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

struct PreviewController: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewControllerNew()
        
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        
        
        
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
    
    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        let parent: PreviewController
        
        func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
            return .disabled
        }
        
        func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem) -> Bool {
            return false
        }
        
        
        
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
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            //                do {
            //                    try FileManager.default.removeItem(atPath: (self.parent.url.path().removingPercentEncoding)!)
            //                } catch {
            //                    print("error??")
            //                }
            //            }
            
            return parent.url as NSURL
        }
        
    }
}





struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var content : ProtectViewModel
    
    @State var opacity : Double = 0.01
    var body: some View {
        VStack{
            if self.content.chosenFiles.count > 0 {
                PreviewController(url: (self.content.chosenFiles.first?.url!)!)
                    .opacity(self.opacity)
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            withAnimation{
                                self.opacity = 1.0
                            }
                        })
                    }
            }else{
                VStack{
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
                EmptyView()
            ,
            trailing:
                NavigationLink(destination: RightsView(content: self.content), label: {
                    HStack{
                        Image(systemName: "list.clipboard")
                            .foregroundColor(.black)
                    }.clipShape(Rectangle())
                })
        )
    }
}
