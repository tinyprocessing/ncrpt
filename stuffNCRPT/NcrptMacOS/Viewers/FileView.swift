//
//  FileView.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import SwiftUI
import SwiftUI
import PDFKit
import UniformTypeIdentifiers


struct FileView: View {
    
    
    @State var content: DecryptDocument = DecryptDocument()
    @ObservedObject var decrypt: ContentDecrypt = ContentDecrypt()
    @ObservedObject var privacy : PrivacyMonitor = PrivacyMonitor.shared

    @State var isPopover = false
    @State var secureFilePopover = false
    @State var one : Bool = false
    
    var urlFromFinder: URL?
    var documentFromFinder: DecryptDocument?
    @State var file : ReferenceFileDocumentConfiguration<DecryptDocument>
    
    
    var body: some View {
        ZStack {
            if (self.decrypt.url == nil) {
                if self.decrypt.error != nil {
                    VStack{
                        configureIcon("Error", size: 145)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: 20){
                            Text(self.decrypt.error!.title)
                                .font(.title)
                                .padding(.bottom, 10)
                            
                            if #available(macOS 12.0, *) {
                                Text(self.decrypt.error!.about)
                                    .font(.title3)
                                    .frame(width: 450)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(10)
                                    .textSelection(.enabled)
                                
                            } else {
                                Text(self.decrypt.error!.about)
                                    .frame(width: 450)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(10)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 30)
                        
                    }
                }else{
                    ActivityIndicator()
                }
            }else {
                if !canViewDocument() {
                    VisualEffectView(material: .popover, blendingMode: .behindWindow, emphasized: false)
                        .overlay(
                            VStack {
                                configureIcon("Error", size: 145)
                                    .padding(.bottom, 20)
                                
                                VStack(spacing: 20) {
                                    Text("File is not supported.")
                                        .padding(.bottom, 10)
                                    
                                    Text("You do not have enough permissions to open this file, contact your administrator.")
                                        .frame(width: 500)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(10)
                                        .padding(.bottom, 10)
                                }
                            }
                        )
                } else {
                    QLViewer(url: self.decrypt.url!)
                        .overlay(
                            VStack{
                                if (self.privacy.hide){
                                    VisualEffectView(material: .popover, blendingMode: .withinWindow, emphasized: false)
                                        .overlay(
                                            VStack{
                                                if (self.privacy.scene == "active"){
                                                    configureIcon("Error", size: 145)
                                                        .padding(.bottom, 20)

                                                    VStack(spacing: 20){
                                                        Text("Screenshot")
                                                            .bold()
                                                            .font(.system(size: 19))
                                                            .padding(.bottom, 10)

                                                        Text("Your device is trying to take a screenshot. The screen will be protected.")
                                                            .frame(width: 450)
                                                            .multilineTextAlignment(.center)
                                                            .lineSpacing(10)
                                                    }
                                                }
                                            }
                                        )
                                }
                            }
                        )
                }
            }
        }
        .onAppear{
            
            if (self.urlFromFinder != nil){
                self.decrypt.openFile(inputURL: self.urlFromFinder!)
            }
        }
        
        .onDrop(of: ["public.url","public.file-url"], isTargeted: nil) { (items) -> Bool in
            print(items)
            if let item = items.first {
                if let identifier = item.registeredTypeIdentifiers.first {
                    print("onDrop with identifier = \(identifier)")
                    if identifier == "public.url" || identifier == "public.file-url" {
                        item.loadItem(forTypeIdentifier: identifier, options: nil) { (urlData, error) in
                            DispatchQueue.main.async {
                                if let urlData = urlData as? Data {
                                    let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                                    self.decrypt.openFile(inputURL: urll)
                                }
                            }
                        }
                    }
                }
                return true
            } else {
                print("item not here")
                return false
            }
        }
        
        .toolbar {
            
           
            ToolbarItem {
                if self.decrypt.secure {
                    Button(action: {
                        isPopover.toggle()
                    }, label: {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.black)
                            
                    })
                    .popover(isPresented: self.$isPopover, arrowEdge: .bottom) {
                        EmptyView()
                            .frame(minWidth: 720,
                                   idealWidth: 720,
                                   maxWidth: 720,
                                   minHeight: 100,
                                   alignment: .center)
                    }
                    .help("Rights")
                }
            }
            
            
            ToolbarItem{
                Text(self.file.fileURL!.lastPathComponent)
                    .font(.title3)
                    .padding(.vertical, 10)
            }
            
            ToolbarItem{
                Spacer()
            }
            
            
            ToolbarItem {
                if (self.decrypt.url?.pathExtension.lowercased() == "pdf") {
                    if false {
                        Button(action: {
                            decrypt.objectWillChange.send()
                            if let url_print = decrypt.url {
                                let document = PDFDocument(url: url_print)
                                let printInfo = NSPrintInfo()
                                
                                printInfo.horizontalPagination = .fit
                                printInfo.verticalPagination = .fit
                                printInfo.isHorizontallyCentered = true
                                printInfo.isVerticallyCentered = true
                                printInfo.leftMargin = 0
                                printInfo.rightMargin = 0
                                printInfo.topMargin = 0
                                printInfo.bottomMargin = 0
                                printInfo.jobDisposition = .spool
                                
                                if let printOperation = document?.printOperation(for: printInfo, scalingMode: .pageScaleNone, autoRotate: false) {
                                    printOperation.showsProgressPanel = false

                                    DispatchQueue.main.async {
                                        if let controller = printOperation.printPanel.value(forKey: "windowController") as? NSWindowController,
                                           let pdfButton = controller.value(forKey: "pdfActionButton") as? NSPopUpButton {
                                            pdfButton.isEnabled = false
                                        }
                                    }
                                    printOperation.run()
                                }
                            }
                        }, label: {
                            Image(systemName: "printer")
                        })
                        .padding(.trailing, 15)
                    }
                }
            }
            
        }
        .frame(minWidth: 600,
               minHeight: 700,
               alignment: .center)

    }

    private func canViewDocument() -> Bool {
        if let url = decrypt.url,
           url.pathExtension == "ppdf" || url.pathExtension == "pdf" {
            return PDFDocument(url: url) != nil
        }
        return true
    }
}

let panel = NSOpenPanel()


extension NSOpenPanel {
    
    static func openImage(completion: @escaping (_ url: URL?, _ data: Data?, _ type: UTType?) -> ()) {
        NCRPT.panel.allowsMultipleSelection = false
        NCRPT.panel.canChooseFiles = true
        NCRPT.panel.canChooseDirectories = false
        NCRPT.panel.allowedContentTypes = [.ncrpt]
        NCRPT.panel.canChooseFiles = true
        NCRPT.panel.begin { (result) in
            if result == .OK {
                let urll = NCRPT.panel.urls.first!
                completion(NCRPT.panel.urls.first!, nil,
                           UTType.types(tag: "ncrpt", tagClass: .filenameExtension, conformingTo: nil).first!)
            }
        }
    }
}

struct PDFViewer: View {
    var url: URL
    @Binding var content: ContentDecrypt
    
    var body: some View {
        ZStack(alignment: .top){
            ZStack{
                GeometryReader { proxy in
                    PDFKitRepresentedView(url, $content)
                        .frame(width: proxy.size.width)
                        .shadow(color: .secondary.opacity(0.3), radius: 10)
                        .cornerRadius(5.0)
                }
            }
        }
    }
}

struct QLViewer: View {
    var url: URL
    
    var body: some View {
        GeometryReader { proxy in
            ZStack{
                Text("")
                    .frame(width: proxy.size.width)
                   
                QuickKitRepresentedView(url)
                    .frame(width: proxy.size.width < ((NSScreen.main?.frame.width)! * 0.55) ? proxy.size.width : (NSScreen.main?.frame.width)! * 0.55)
            }.frame(width: proxy.size.width)
        }
    }
}
