//
//  SecureFileView.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 16.11.2022.
//

import SwiftUI


struct SecureFileView: View {
    @ObservedObject var pvm: ProtectViewModel
    @State var files : [fileItem] = []
    @State private var isImporting: Bool = false
    @State private var presentAddUsers = false
    @State private var username: String = ""
    
    @State private var showNewUser = false
    @State private var showEditUser = false
    @State private var showNewTemplate = false
    @State private var showEditTemplate = false

    var body: some View {
        VStack{
            ZStack(alignment: .bottom){
                Form {
                    
                    //MARK: - Templates
                    Section(header: Text("Protect by template")) {
                        ForEach(pvm.templates) { templ in
                            HStack{
                                Image(systemName: pvm.isCurTemplate( templ) ? "checkmark.square" : "square")
                                    .foregroundColor(pvm.isCurTemplate(templ) ? .green : .secondary)
                                    .onTapGesture {
                                        pvm.selectTemplate(templ.id)
                                    }
                                Text(templ.name)
                                Spacer()
                                Button {
                                    showEditTemplate.toggle()
                                } label: {
                                    Image(systemName: "info.circle")
                                }
                                .foregroundColor(Color(0x1d3557))
                                .overlay(
                                    NavigationLink(
                                        destination: { TemplateView(vm: pvm, template: templ, selectedRights: templ.rights) },
                                        label: { EmptyView() }
                                    ).opacity(0)
                                )
                                
                            }
                            
                        }
                        .onDelete(perform: deleteTemplate)
                        
                        Button {
                            showNewTemplate.toggle()
                        } label: {
                            HStack{
                                Spacer()
                                Image(systemName: "plus.circle")
                                Text("Add new template")
                                Spacer()
                            }.foregroundColor(Color(0x1d3557))
                        }
                        .overlay(
                            NavigationLink(
                                destination: { TemplateView(vm: pvm, isNewTemplate: true) },
                                label: { EmptyView() }
                            ).opacity(0)
                        )
                        
                    }
                    
                    //MARK: - Users
                    Section(header: Text("Users")) {
                        ForEach(pvm.recentUsers){ user in
                            HStack{
                                Image(systemName: pvm.isSelUser(user) ? "checkmark.square" : "square")
                                    .foregroundColor(pvm.isSelUser(user) ? .green : .secondary)
                                    .onTapGesture {
                                        pvm.addSelectUser(user)
                                    }
                                VStack(alignment: .leading) {
                                    Text(user.email)
                                    Text(user.allRights)
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 10))
                                }
                                Spacer()
                                Button {
                                    showEditUser.toggle()
                                } label: {
                                    Image(systemName: "chevron.right")
                                }.foregroundColor(Color(0x1d3557))
                                    .overlay(
                                        NavigationLink(
                                            destination: { UserRightsView(vm: pvm, user: user, selectedRights: user.rights) },
                                            label: { EmptyView() }
                                        ).opacity(0)
                                    )
                            }
                        }
                        .onDelete(perform: deleteUser)
                        Button {
                            showNewUser.toggle()
                        } label: {
                            HStack{
                                Spacer()
                                Image(systemName: "plus.circle")
                                Text("Add new user")
                                Spacer()
                            }.foregroundColor(Color(0x1d3557))
                        }
                        .overlay(
                            NavigationLink(
                                destination: { UserRightsView(vm: pvm, isNewUser: true) },
                                label: { EmptyView() }
                            ).opacity(0)
                        )
                        
                    }
                    //MARK: - Files
                    Section(header: Text("Selected files")) {
                        ForEach(pvm.chosenFiles, id:\.self){ file in
                            HStack {
                                Text(file.name)
                                Spacer()
                                Text(file.size)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deleteFile)
                        
                        
                        Button {
                            isImporting = true
                        } label: {
                            HStack{
                                Spacer()
                                Image(systemName: "plus.circle")
                                Text("Add file")
                                Spacer()
                            }.foregroundColor(Color(0x1d3557))
                            
                        }
                    }
                    .fileImporter(
                        isPresented: $isImporting,
                        allowedContentTypes: pvm.getAtualTypes(),
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            pvm.addFileURL(selectedFile)
                        } catch {
                            // Handle failure.
                        }
                    }
                    
                    
                }
                
                Button(action: {
                    print("----Ecrypting-----")
                    print("-template: \(pvm.templates.first{$0.id == pvm.selectedTemplated}?.name)")
                    print("-files: \(pvm.chosenFiles)")
                    
                    //Check chosen files
                    let polygone = Polygone()
                    if pvm.chosenFiles.count > 0 {
                        polygone.encryptFile((pvm.chosenFiles.first?.url)!, users: pvm.selectedResentUsers) { success in
                            print(success)
                            Settings.shared.alert(title: "Success", message: "Your files are protected, you can find them on home page")
                        }
                    }
                }, label: {
                    HStack {
                        Spacer()
                        Text("protect file")
                            .padding(.horizontal, 55)
                            .padding(.vertical, 10)
                            .background(pvm.chosenFiles.count > 0 && pvm.selectedResentUsers.count > 0 ? Color.init(hex: "4378DB") : Color.init(hex: "4378DB").opacity(0.1))
                            .cornerRadius(8.0)
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                    
                    
                })
                
            }
            .onAppear{
                self.pvm.loadUsers()
                self.pvm.loadTemplates()
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: pvm.getAtualTypes(),
                allowsMultipleSelection: true
            ) { result in
                do {
                    guard let selected: [URL]? = try result.get() else { return }
                    if let files = selected {
                        files.forEach { file in
                            file.startAccessingSecurityScopedResource()
                            self.files.append(fileItem(id: 0, name: file.lastPathComponent, url: file, ext: file.pathExtension.lowercased()))
                            
                            pvm.addFileURL(file)
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        .navigationTitle("protection")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    func deleteUser(at offsets: IndexSet) {
        pvm.removeUser(at: offsets)
    }
    
    func deleteFile(at offsets: IndexSet) {
        pvm.chosenFiles.remove(atOffsets: offsets)
    }
    
    func deleteTemplate(at offsets: IndexSet) {
        pvm.removeTemplate(at: offsets)
    }
}

struct SecureFileView_Previews: PreviewProvider {
    static var previews: some View {
        SecureFileView(pvm: ProtectViewModel())
    }
}
