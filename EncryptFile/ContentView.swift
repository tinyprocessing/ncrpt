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

struct ContentView: View {
    
    @State private var showingContent = false
    @State private var isShowMenu = false
    @ObservedObject var localFiles: LocalFileEngine = LocalFileEngine.shared
    @State private var document: FileDocumentStruct = FileDocumentStruct()
    @State private var isImporting: Bool = false
    @State private var isImportingEncrypt: Bool = false
    @State private var isImportingDecrypt: Bool = false
    @State var content : URL? = nil
    @State var secureOpen: Bool = false
    
    
    var body: some View {
        NavigationView{
            ZStack {
                Color.init(hex: "F2F5F8")
                    .edgesIgnoringSafeArea(.top)
                if isShowMenu {
                    SideMenu(isShowMenu: $isShowMenu)
                }
                ZStack(alignment: .bottomTrailing) {
                    Color.white
                    VStack{
                        VStack{
                            HStack{
                                Text("Folders")
                                    .modifier(NCRPTTextSemibold(size: 18))
                                    .foregroundColor(Color.init(hex: "21205A"))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 15)
                            
                            VStack(spacing: 15){
                                HStack{
                                    Button(action: {
                                        
                                    }, label: {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.init(hex: "4378DB").opacity(0.16))
                                                .frame(height: 125)
                                            HStack{
                                                VStack(alignment: .leading, spacing: 15){
                                                    Image("blueFolder")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 30, height: 30, alignment: .center)
                                                    
                                                    Text("Work")
                                                        .modifier(NCRPTTextMedium(size: 15))
                                                        .foregroundColor(Color.init(hex: "4378DB"))
                                                    
                                                    Text("0 files")
                                                        .modifier(NCRPTTextRegular(size: 14))
                                                        .foregroundColor(Color.init(hex: "4378DB").opacity(0.7))
                                                }
                                                Spacer()
                                                VStack{
                                                    Text(":")
                                                        .modifier(NCRPTTextSemibold(size: 20))
                                                        .foregroundColor(Color.init(hex: "4378DB"))
                                                        .padding(10)
                                                    Spacer()
                                                }
                                                
                                            }
                                            .padding(.horizontal, 10)
                                            .frame(height: 125)
                                        }
                                    })
                                    
                                    Spacer(minLength: 15)
                                    
                                    Button(action: {
                                        
                                    }, label: {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.init(hex: "F0A714").opacity(0.16))
                                                .frame(height: 125)
                                            HStack{
                                                VStack(alignment: .leading, spacing: 15){
                                                    Image("yellowFolder")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 30, height: 30, alignment: .center)
                                                    
                                                    Text("iCloud")
                                                        .modifier(NCRPTTextMedium(size: 15))
                                                        .foregroundColor(Color.init(hex: "F0A714"))
                                                    
                                                    Text("0 files")
                                                        .modifier(NCRPTTextRegular(size: 14))
                                                        .foregroundColor(Color.init(hex: "F0A714").opacity(0.7))
                                                    
                                                }
                                                Spacer()
                                                VStack{
                                                    Text(":")
                                                        .modifier(NCRPTTextSemibold(size: 20))
                                                        .foregroundColor(Color.init(hex: "F0A714"))
                                                        .padding(10)
                                                    Spacer()
                                                }
                                                
                                            }
                                            .padding(.horizontal, 10)
                                            .frame(height: 125)
                                            
                                        }
                                    })
                                    
                                }.padding(.horizontal, 20)
                                HStack{
                                    Button(action: {
                                        
                                    }, label: {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.init(hex: "F35555").opacity(0.16))
                                                .frame(height: 125)
                                            HStack{
                                                VStack(alignment: .leading, spacing: 15){
                                                    Image("redFolder")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 30, height: 30, alignment: .center)
                                                    
                                                    Text("Shared")
                                                        .modifier(NCRPTTextMedium(size: 15))
                                                        .foregroundColor(Color.init(hex: "F35555"))
                                                    
                                                    Text("0 files")
                                                        .modifier(NCRPTTextRegular(size: 14))
                                                        .foregroundColor(Color.init(hex: "F35555").opacity(0.7))
                                                }
                                                Spacer()
                                                VStack{
                                                    Text(":")
                                                        .modifier(NCRPTTextSemibold(size: 20))
                                                        .foregroundColor(Color.init(hex: "F35555"))
                                                        .padding(10)
                                                    Spacer()
                                                }
                                                
                                            }
                                            .padding(.horizontal, 10)
                                            .frame(height: 125)
                                        }
                                    })
                                    
                                    Spacer(minLength: 15)
                                    
                                    Button(action: {
                                        
                                    }, label: {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.init(hex: "28A164").opacity(0.16))
                                                .frame(height: 125)
                                            HStack{
                                                VStack(alignment: .leading, spacing: 15){
                                                    Image("greenFolder")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 30, height: 30, alignment: .center)
                                                    
                                                    Text("My Files")
                                                        .modifier(NCRPTTextMedium(size: 15))
                                                        .foregroundColor(Color.init(hex: "28A164"))
                                                    
                                                    Text("0 files")
                                                        .modifier(NCRPTTextRegular(size: 14))
                                                        .foregroundColor(Color.init(hex: "28A164").opacity(0.7))
                                                    
                                                }
                                                Spacer()
                                                VStack{
                                                    Text(":")
                                                        .modifier(NCRPTTextSemibold(size: 20))
                                                        .foregroundColor(Color.init(hex: "28A164"))
                                                        .padding(10)
                                                    Spacer()
                                                }
                                                
                                            }
                                            .padding(.horizontal, 10)
                                            .frame(height: 125)
                                            
                                        }
                                    })
                                    
                                }.padding(.horizontal, 20)
                            }
                            
                            HStack{
                                Text("Recent Files")
                                    .modifier(NCRPTTextSemibold(size: 18))
                                    .foregroundColor(Color.init(hex: "21205A"))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top)
                            
                            ScrollView(.vertical, showsIndicators: false){
                                VStack(spacing: 0){
                                    ForEach(self.localFiles.files, id:\.self) { file in
                                        HStack(spacing: 15){
                                            HStack(spacing: 10){
                                                Image(file.ext)
                                                    .resizable()
                                                    .frame(width: 20, height: 20, alignment: .center)
                                                Text("\(file.name)")
                                                    .modifier(NCRPTTextMedium(size: 16))
                                                    .onTapGesture {
                                                        if file.url != nil {
                                                            DispatchQueue.global(qos: .userInitiated).async {
                                                                let polygone = Polygone()
                                                                polygone.decryptFile(file.url!) { url, success in
                                                                    if success {
                                                                        self.content = url
                                                                        DispatchQueue.main.async {
                                                                            showingContent.toggle()
                                                                        }
                                                                    }else{
                                                                        Settings.shared.alert(title: "Error", message: "File is not supported", buttonName: "close")
                                                                    }
                                                                }
                                                                
                                                            }
                                                        }
                                                    }
                                            }
                                            Spacer()
                                            
                                            Menu(":") {
                                                
                                                Button(action: {
                                                    share(items: [file.url!])
                                                }) {
                                                    Label("Share", systemImage: "square.and.arrow.up")
                                                }
                                                
                                                Button(action: {
                                                    do {
                                                        try FileManager.default.removeItem(atPath: (file.url?.path().removingPercentEncoding)!)
                                                        self.localFiles.getLocalFiles()
                                                    } catch {
                                                        print("Could not delete file, probably read-only filesystem")
                                                    }
                                                }) {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                                
                                            }
                                            .contentShape(Rectangle())
                                            .padding(10)
                                            .modifier(NCRPTTextMedium(size: 20))
                                            
                                            
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        Spacer()
                    }
                    .fileImporter(
                        isPresented: $isImporting,
                        allowedContentTypes: [.ncrpt, .zip],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            self.document.url = selectedFile
                            let one = selectedFile.startAccessingSecurityScopedResource()
                            //                            if self.isImportingEncrypt {
                            //                                let polygone = Polygone()
                            //                                polygone.encryptFile(self.document.url!)
                            //                                localFiles.getLocalFiles()
                            //                            }
                            
                            if self.isImportingDecrypt {
                                let polygone = Polygone()
                                polygone.decryptFile(self.document.url!) { url, success in
                                    if success {
                                        self.content = url
                                        showingContent.toggle()
                                    }else{
                                        Settings.shared.alert(title: "Error", message: "File is not supported", buttonName: "close")
                                    }
                                }
                            }
                        } catch {
                            // Handle failure.
                        }
                    }
                    .sheet(isPresented: $showingContent) {
                        SheetView(content: self.$content)
                    }
                    
                    
                    NavigationLink(destination: SecureFileView(), label: {
                        ZStack{
                            Circle()
                                .fill(Color.init(hex: "4378DB"))
                                .frame(width: 64, height: 64, alignment: .center)
                                .padding(.horizontal)
                            Image("lock")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22, alignment: .center)
                        }
                    })
                 
                    VisualEffect(style: .prominent)
                        .opacity(isShowMenu ? 0.8 : 0)
                    
                }
                .navigationBarItems(
                    leading:
                        Button(action: {
                            withAnimation(.spring()) {
                                self.isShowMenu = true
                            }
                        }, label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.black)
                        })
                    ,
                    trailing:
                        
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                        })
                )
                .cornerRadius(20)
                .offset(x: isShowMenu ? 210 : 0, y: isShowMenu ? 44 : 0)
                .navigationTitle("ncrpt.io")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear{
                    self.localFiles.getLocalFiles()
                }
               
            }
        }
        .background(.red)
        .accentColor(.black)
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


struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


struct VisualEffect: UIViewRepresentable {
    @State var style : UIBlurEffect.Style // 1
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style)) // 2
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    } // 3
}
