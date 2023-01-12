//
//  ContentView.swift
//  EncryptFile
//
//  Created by Michael Safir on 25.10.2022.
//

import SwiftUI

struct ContentView: View {
    
    
    @State private var showingRights = false

    @State private var isShowMenu = false
    @ObservedObject var localFiles: LocalFileEngine = LocalFileEngine.shared
    @State private var document: FileDocumentStruct = FileDocumentStruct()
    @StateObject var pvm = ProtectViewModel()
    @State private var isImporting: Bool = false
    @State private var isImportingEncrypt: Bool = false
    @State private var isImportingDecrypt: Bool = false
    @ObservedObject var content : ProtectViewModel = ProtectViewModel.shared
    @State var showProtectionView = false
    
    var body: some View {
        NavigationView{
            ZStack {
                Color.init(hex: "F2F5F8")
                    .edgesIgnoringSafeArea(.top)
                if isShowMenu {
                    SideMenu(isShowMenu: $isShowMenu, pvm: pvm)
                }
                ZStack(alignment: .bottomTrailing) {
                    Color.white
                    VStack{
                        if self.localFiles.files.count > 0 {
                            VStack(spacing: 0){
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
                                                    // file.ext
                                                    Image("file")
                                                        .resizable()
                                                        .frame(width: 20, height: 20, alignment: .center)
                                                    Text("\(file.name)")
                                                        .modifier(NCRPTTextMedium(size: 16))
                                                        .onTapGesture {
                                                            self.content.chosenFiles = []
                                                            DispatchQueue.main.async {
                                                                self.content.showingContent.toggle()
                                                            }
                                                            
                                                            if file.url != nil {
                                                                DispatchQueue.global(qos: .userInitiated).async {
                                                                    let polygone = Polygone()
                                                                    polygone.decryptFile(file.url!) { url, rights, success  in
                                                                        if success {
                                                                            self.content.objectWillChange.send()
                                                                            self.content.chosenFiles = [Attach(url: url)]
                                                                            self.content.rights = rights
                                                                            self.content.objectWillChange.send()
                                                                        }else{
                                                                            Settings.shared.alert(title: "Error", message: "You do not have enough permissions to open this file, contact your administrator.", buttonName: "close")
                                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                                                self.content.showingContent.toggle()
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                            }
                                                        }
                                                }
                                                Spacer()
                                                
                                                Menu(content: {
                                                    
                                                    Button(action: {
                                                        share(items: [file.url!])
                                                    }) {
                                                        Label("Share", systemImage: "square.and.arrow.up")
                                                    }
                                                    
                                                    Button(action: {
                                                        
                                                        if file.url != nil {
                                                            DispatchQueue.global(qos: .userInitiated).async {
                                                                let polygone = Polygone()
                                                                polygone.decryptFile(file.url!) { url, rights, success  in
                                                                    if success {
                                                                        self.content.objectWillChange.send()
                                                                        self.content.chosenFiles = [Attach(url: url)]
                                                                        self.content.rights = rights
                                                                        self.content.objectWillChange.send()
                                                                        
                                                                        DispatchQueue.main.async {
                                                                            showingRights.toggle()
                                                                        }
                                                                        
                                                                    }else{
                                                                        Settings.shared.alert(title: "Error", message: "You do not have enough permissions to open this file, contact your administrator.", buttonName: "close")
                                                                    }
                                                                }
                                                                
                                                            }
                                                        }
                                                    }) {
                                                        Label("Rights", systemImage: "list.clipboard")
                                                    }
                                                    
                                                    Button(role: .destructive, action: {
                                                        print("revoke file from server")
                                                        Settings.shared.alertViewWithCompletion(title: "Sure?", message: "File will be revoked and deleted from server and device.") { result in
                                                            if result {
                                                                let polygone = Polygone()
                                                                let md5 = polygone.getFileMD5(file.url!)
                                                                if let md5 = md5 {
                                                                    Network.shared.revoke(fileMD5: md5) { success in
                                                                        if success {
                                                                            do {
                                                                                try FileManager.default.removeItem(atPath: (file.url?.path().removingPercentEncoding)!)
                                                                                self.localFiles.getLocalFiles()
                                                                            } catch {
                                                                                print("Could not delete file, probably read-only filesystem")
                                                                            }
                                                                        }else{
                                                                            Settings.shared.alert(title: "Error", message: "Server is not able to revoke", buttonName: "close")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }

                                                    }) {
                                                        Label("Revoke", systemImage: "network")
                                                            .foregroundColor(.red)
                                                    }
                                                    
                                                    Button(role: .destructive, action: {
                                                        Settings.shared.alertViewWithCompletion(title: "Sure?", message: "File will be deleted from device.") { result in
                                                            if result {
                                                                do {
                                                                    try FileManager.default.removeItem(atPath: (file.url?.path().removingPercentEncoding)!)
                                                                    self.localFiles.getLocalFiles()
                                                                } catch {
                                                                    print("Could not delete file, probably read-only filesystem")
                                                                }
                                                            }
                                                        }
                                                    }) {
                                                        Label("Delete", systemImage: "trash")
                                                            .foregroundColor(.red)
                                                    }
                                                }, label: {
                                                    Text(":")
                                                        .modifier(NCRPTTextSemibold(size: 20))
                                                        .foregroundColor(.black)
                                                        .padding(10)
                                                })
                                                .contentShape(Rectangle())
                                                .modifier(NCRPTTextMedium(size: 20))
                                                
                                                
                                                
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            Spacer()
                        }else{
                            Spacer()
                            HStack{
                                Spacer()
                                Text("No files yet")
                                    .modifier(NCRPTTextSemibold(size: 18))
                                    .foregroundColor(Color.init(hex: "21205A"))
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    .fileImporter(
                        isPresented: $isImporting,
                        allowedContentTypes: [.ncrpt],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            self.document.url = selectedFile
                            let one = selectedFile.startAccessingSecurityScopedResource()
                           
                            self.content.chosenFiles = []
                            DispatchQueue.main.async {
                                self.content.showingContent.toggle()
                            }
                            
                            let polygone = Polygone()
                            polygone.decryptFile(self.document.url!) { url, rights, success in
                                if success {
                                    self.content.chosenFiles = [Attach(url: url)]
                                    self.content.rights = rights
                                }else{
                                    Settings.shared.alert(title: "Error", message: "You do not have enough permissions to open this file, contact your administrator.", buttonName: "close")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.content.showingContent.toggle()
                                    }
                                }
                            }
                        } catch {
                            // Handle failure.
                        }
                    }
                    
                    NavigationLink(destination: SheetView(content: self.content), isActive: self.$content.showingContent) {
                        EmptyView()
                    }
                    
                    NavigationLink(destination: RightsView(content: self.content), isActive: $showingRights) {
                        EmptyView()
                    }
                    
                    NavigationLink(destination: SecureFileView(pvm: pvm), label: {
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
                        .shadow(radius: 5)
                        .padding(.bottom, 5)
                    })
                 
                    VisualEffect(style: .prominent)
                        .opacity(isShowMenu ? 0.6 : 0)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                self.isShowMenu = false
                            }
                        }
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
                            self.isImporting.toggle()
                        }, label: {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                        })
                )
                .cornerRadius(20)
                .offset(x: isShowMenu ? 210 : 0)
                .navigationTitle("ncrpt.io")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear{
                    self.localFiles.getLocalFiles()
                }
               
            }
        }
        .background(.red)
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.black)
        .onAppear{
            Network.shared.contacts { result in
                
            }
        }
        .onOpenURL { url in
            self.content.chosenFiles = []
            self.content.showingContent = false
            
            DispatchQueue.main.async {
                self.content.showingContent.toggle()
            }
            
            let polygone = Polygone()
            polygone.decryptFile(url) { url, rights, success in
                if success {
                    self.content.chosenFiles = [Attach(url: url)]
                    self.content.rights = rights
                }else{
                    Settings.shared.alert(title: "Error", message: "You do not have enough permissions to open this file, contact your administrator.", buttonName: "close")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.content.showingContent.toggle()
                    }
                }
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

struct DeleteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.red)
    }
}
