//
//  ProtectionView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 03.11.2022.
//

import SwiftUI

struct ProtectionView: View {
    @StateObject var vm = ProtectViewModel()
    @State private var document: FileDocumentStruct = FileDocumentStruct()
    @State private var isImporting = false
    @State private var showNewUser = false
    @State private var showEditUser = false
    @State private var showNewTemplate = false
    @State private var showEditTemplate = false
    
    var body: some View {
        ZStack{
            
            VStack{
                
                Form {
                    
                    //MARK: - Templates
                    Section(header: Text("Protect by template")) {
                        ForEach(vm.templates) { templ in
                            HStack{
                                Image(systemName: vm.isCurTemplate( templ) ? "checkmark.square" : "square")
                                    .foregroundColor(vm.isCurTemplate(templ) ? .green : .secondary)
                                    .onTapGesture {
                                        vm.selectTemplate(templ.id)
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
                                        destination: { TemplateView(vm: vm, template: templ, selectedRights: templ.rights) },
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
                                destination: { TemplateView(vm: vm, isNewTemplate: true) },
                                label: { EmptyView() }
                            ).opacity(0)
                        )
                        
                    }
                    
                    //MARK: - Users
                    Section(header: Text("Users")) {
                        ForEach(vm.recentUsers){ user in
                            HStack{
                                Image(systemName: vm.isSelUser(user) ? "checkmark.square" : "square")
                                    .foregroundColor(vm.isSelUser(user) ? .green : .secondary)
                                    .onTapGesture {
                                        vm.addSelectUser(user)
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
                                            destination: { UserRightsView(vm: vm, user: user, selectedRights: user.rights) },
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
                                destination: { UserRightsView(vm: vm, isNewUser: true) },
                                label: { EmptyView() }
                            ).opacity(0)
                        )
                        
                    }
                    //MARK: - Files
                    Section(header: Text("Selected files")) {
                        ForEach(vm.chosenFiles, id:\.self){ file in
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
                        allowedContentTypes: vm.getAtualTypes(),
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            vm.addFileURL(selectedFile)
                        } catch {
                            // Handle failure.
                        }
                    }
                    
                    Button {
                        print("----Ecrypting-----")
                        print("-template: \(vm.templates.first{$0.id == vm.selectedTemplated}?.name)")
                        print("-files: \(vm.chosenFiles)")
                    } label: {
                        Text("Encrypt")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(0x1d3557), Color(0xa8dadc)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                }
                
            }
            
        }
        .navigationTitle("")
    }
    
    func deleteUser(at offsets: IndexSet) {
        vm.recentUsers.remove(atOffsets: offsets)
    }
    
    func deleteFile(at offsets: IndexSet) {
        vm.chosenFiles.remove(atOffsets: offsets)
    }
    
    func deleteTemplate(at offsets: IndexSet) {
        vm.templates.remove(atOffsets: offsets)
    }
}

struct ProtectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProtectionView()
    }
}
