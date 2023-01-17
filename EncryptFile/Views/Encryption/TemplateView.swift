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
    
    func checkTemplateStatus() -> Bool {
        if self.usersInTamplate.count > 0 && !self.templateFieldInput.isEmpty {
            return true
        }
        return false
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom){
            
            ScrollView(.vertical, showsIndicators: false){
                VStack(alignment: .leading, spacing: 15){
                    VStack(alignment: .leading, spacing: 15){
                        HStack{
                            Text("Template Name")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color.init(hex: "21205A"))
                            Spacer()
                        }
                        .padding(.horizontal)
                        HStack{
                            VStack(alignment: .leading) {
                                if isNewTemplate {
                                    TextField("Write...", text: $templateFieldInput)
                                        .frame(height: 30)
                                } else {
                                    TextField("Write...", text: Binding<String>(
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
                        .padding(.horizontal)
                        HStack{
                            Text("Users")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color.init(hex: "21205A"))
                            Spacer()
                            
                            NavigationLink(
                                destination: {
                                    TemplateUserView(vm: vm, isNewUser: true, usersInTamplate: $usersInTamplate)
                                },
                                label: {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(Color.black)
                                }
                            )
                            
                        }
                        .padding(.horizontal)
                        if usersInTamplate.count == 0 {
                            HStack{
                                Spacer()
                                Text("no users in list")
                                Spacer()
                            }.padding()
                        }
                        
                        ForEach(usersInTamplate){ user in
                            
                            NavigationLink(
                                destination: {
                                    TemplateUserView(vm: vm, user: user, selectedRights: user.rights, usersInTamplate: $usersInTamplate) },
                                label: {
                                    HStack{
                                        VStack(alignment: .leading) {
                                            Text(user.name)
                                                .foregroundColor(.black)
                                                .modifier(NCRPTTextMedium(size: 14))
                                            Text(user.email)
                                                .modifier(NCRPTTextMedium(size: 14))
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 10))
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                        
                                    }.padding(.vertical, 5)
                                }
                            )
                            .padding(.horizontal)
                            .background(Color.white)
                            .contextMenu {
                                Button(role: .destructive, action: {
                                    var tmpArray : [User] = []
                                    self.usersInTamplate.forEach { userItem in
                                        if userItem.id != user.id {
                                            tmpArray.append(userItem)
                                        }
                                    }
                                    self.usersInTamplate = tmpArray
                                }) {
                                    Label("Delete", systemImage: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            
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
                HStack {
                    Spacer()
                    Text(isNewTemplate ? "Add template" : "Save template")
                        .modifier(NCRPTTextMedium(size: 16))
                        .padding(.horizontal, 55)
                        .padding(.vertical, 10)
                        .background(checkTemplateStatus() ? Color.init(hex: "4378DB") : Color.init(hex: "4378DB").opacity(0.1))
                        .cornerRadius(8.0)
                        .foregroundColor(Color.white)
                    Spacer()
                }
            }
        }
        .navigationTitle(isNewTemplate ? "New template" : "Edit template")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    func loadTemplate() {
        templateFieldInput = template?.name ?? ""
    }
    
}

struct TemplateView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateView(vm: ProtectViewModel())
    }
}
