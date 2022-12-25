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



class RestrictedTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        OperationQueue.main.addOperation({
            UIMenuController.shared.setMenuVisible(false, animated: false)
        })
        if action == #selector(UIResponderStandardEditActions.paste(_:))  || action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.cut(_:)){
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension UIView {
    func preventScreenshot() {
        guard superview != nil else {
            for subview in subviews {
                subview.preventScreenshot()
            }
            return
        }
        
        let guardTextField = RestrictedTextField()
        guardTextField.backgroundColor = .white
        guardTextField.translatesAutoresizingMaskIntoConstraints = false
        guardTextField.tag = Int.max
        guardTextField.isSecureTextEntry = true
        print(interactions)
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
       return false
    }
}

var deep = 0
func removeAllStaff<T>(_ view: inout T){
    if deep > 500 {
        return
    }
    deep += 1
    if type(of: view) == EncryptFile.QLPreviewControllerNew.self {
        let viewsCheck = view as! QLPreviewControllerNew
        var tmp = viewsCheck.navigationController
        removeAllStaff(&tmp)
    }
    if view is UINavigationController {
        let viewsCheck = view as! UINavigationController
        viewsCheck.viewControllers.forEach { controller in
            var tmp = controller
            removeAllStaff(&tmp)
        }
    }
    if view is  UIViewController {
        let viewsCheck = view as! UIViewController
        viewsCheck.children.forEach { controller in
            var tmp = controller
            removeAllStaff(&tmp)
        }
        print(viewsCheck.view.interactions)
        viewsCheck.view.subviews.forEach { controller in
            var tmp = controller
            removeAllStaff(&tmp)
        }
    }
    if view is UIView {
        let viewsCheck = view as? UIView
        if viewsCheck != nil {
            print(viewsCheck!.interactions)
            if viewsCheck!.interactions.count > 0{
                viewsCheck!.interactions.forEach { iter in
                    viewsCheck!.removeInteraction(iter)
                    viewsCheck!.isUserInteractionEnabled = false
                }
            }
            viewsCheck!.subviews.forEach { controller in
                var tmp = controller
                removeAllStaff(&tmp)
            }
        }
    }
}

struct PreviewController: UIViewControllerRepresentable {
    let url: URL
    var controller = QLPreviewControllerNew()
    
    func removeAllSubviews(subviews: [UIView]){
        subviews.forEach { view in
            view.interactions.forEach { iter in
                print(iter)
                view.removeInteraction(iter)
            }
            removeAllSubviews(subviews: view.subviews)
        }
    }
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        
        
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            controller.view.subviews.forEach { view in
                view.preventScreenshot()
                print(view)
            }
        }
        
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
    @ObservedObject var content : ProtectViewModel = ProtectViewModel.shared
    
    @State var currentDate = Date.now
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    
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
