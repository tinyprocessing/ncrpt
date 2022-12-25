//
//  TemplateView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 07.11.2022.
//

import SwiftUI

struct TemplateView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var vm: ProtectViewModel
    @State var template: Template?
    @State var isNewTemplate = false
    @State var templateFieldInput = ""
    @State var selectedRights = Set<String>()
    @State var usersInTamplate = [User]()
    
    @State private var showNewUser = false
    @State private var showEditUser = false
    
    @State var chosenPermission = ""
    
    var body: some View {
            Form {
                //MARK: template header
                Section(header: Text("Name of Template")){
                    VStack(alignment: .leading) {
                        if isNewTemplate {
                            TextField("Type new template name", text: $templateFieldInput)
                                .frame(height: 30)
                                .padding(.horizontal, 10)
                        } else {
                            TextField("", text: Binding<String>(
                                get: { self.templateFieldInput },
                                set: {
                                    self.templateFieldInput = $0
                                    self.template?.name = self.templateFieldInput
                                }))
                            .onAppear(perform: loadTemplate)
                                .frame(height: 30)
                            
                        }
                        
                    }
                    
                }
                
                //MARK: users
                Section(header: Text("Users")) {
                    ForEach(usersInTamplate){ user in
                        HStack{
                            VStack(alignment: .leading) {
                                Text(user.name)
                                Text(user.email)
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
                                        destination: {
                                            TemplateUserView(vm: vm, user: user, selectedRights: user.rights, usersInTamplate: $usersInTamplate) },
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
                            destination: {
                                TemplateUserView(vm: vm, isNewUser: true, usersInTamplate: $usersInTamplate)
                            },
                            label: { EmptyView() }
                        ).opacity(0)
                    )
                }

                
                //MARK: permissions
//                Section(header: Text("Choose permissions")) {
//                    List(selection: $selectedRights) {
//                        ForEach(vm.permissionSet, id: \.self) { item in
//                            HStack {
//                                Text("\(item)")
//                                Spacer()
//                                Image(systemName: selectedRights.contains(item) ? "checkmark.square" : "square")
//                                    .foregroundColor(selectedRights.contains(item) ? .green : .secondary)
//                            }
//                            .contentShape(Rectangle())
//                            .onTapGesture {
//                                if  selectedRights.contains(item) {
//                                    selectedRights.remove(item)
//                                }
//                                else{
//                                    selectedRights.insert(item)
//                                }
//                                print(selectedRights)
//                            }
//                            
//                        }
//                    }
//                }
                
                //MARK: safe/edit user button
                Button {
                    if !templateFieldInput.isEmpty {
                        if isNewTemplate {
                            //add new template
                            vm.addTemplate(Template(name: templateFieldInput,
                                                    rights: selectedRights,
                                                    users: Set(usersInTamplate)),
                                           new: true)
                        } else {
                            //edit template
                            vm.addTemplate(Template(id: template!.id,
                                                    name: templateFieldInput,
                                                    rights: selectedRights,
                                                    users: Set(usersInTamplate)))
                        }

                        self.presentation.wrappedValue.dismiss()
                    }
                } label: {
                    Text(isNewTemplate ? "Add template" : "Edit template")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Color(0x1d3557))
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
            }.navigationTitle(isNewTemplate ? "New template" : "Edit template")
    }
    
    
    func loadTemplate() {
        templateFieldInput = template?.name ?? ""
    }
    
    func deleteUser(at offsets: IndexSet) {
        usersInTamplate.remove(atOffsets: offsets)
    }
    
}

struct TemplateView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateView(vm: ProtectViewModel())
    }
}
