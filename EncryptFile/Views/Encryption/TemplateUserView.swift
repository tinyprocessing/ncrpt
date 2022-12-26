//
//  TemplateUserView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 25.12.2022.
//

import SwiftUI

struct TemplateUserView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var vm: ProtectViewModel
    @State var user: User?
    @State var isNewUser = false
    @State var nameFieldInput = ""
    @State var emailFieldInput = ""
    @State var selectedRights = Set<String>()
    @Binding var usersInTamplate: [User]
    
    @State var chosenPermission = ""

    var body: some View {
        
        Form {
            //header
            Section(){
                VStack(alignment: .leading) {
                    if isNewUser {
                        TextField("Type name", text: $nameFieldInput)
                            .frame(height: 30)
                            .padding(.horizontal, 10)
                        Divider()
                        TextField("Type email", text: $emailFieldInput)
                            .frame(height: 30)
                            .padding(.horizontal, 10)
                    } else {
                        TextField("", text: Binding<String>(
                            get: { self.nameFieldInput },
                            set: {
                                self.nameFieldInput = $0
                                self.user?.name = self.nameFieldInput
                            }))
                        .frame(height: 30)
                        Divider()
                        TextField("", text: Binding<String>(
                            get: { self.emailFieldInput },
                            set: {
                                self.emailFieldInput = $0
                                self.user?.email = self.emailFieldInput
                            }))
                        .frame(height: 30)
                        .onAppear(perform: loadMail)
                    }
                    
                }
                
            }
            //permissions
            Section(header: Text("Choose permissions")) {
                List(selection: $selectedRights) {
                    ForEach(vm.permissionSet, id: \.self) { item in
                        HStack {
                            Text("\(item)")
                            Spacer()
                            Image(systemName: selectedRights.contains(item) ? "checkmark.square" : "square")
                                .foregroundColor(selectedRights.contains(item) ? .green : .secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if  selectedRights.contains(item) {
                                selectedRights.remove(item)
                            }
                            else{
                                selectedRights.insert(item)
                            }
                            print(selectedRights)
                        }
   
                    }
                }
            }
            
            //MARK: edit user button
            Button {
                if !emailFieldInput.isEmpty {
                    if isNewUser {
                        print(nameFieldInput)
                        print(emailFieldInput)
                        print(selectedRights)
                        usersInTamplate.append(User(name: nameFieldInput,
                                                    email: emailFieldInput,
                                                    rights: selectedRights))
                        
                    } else {
                        if let inx = usersInTamplate.firstIndex(where: { $0.id == user!.id }) {
                            usersInTamplate[inx] = User(id: user!.id,
                                                        name: nameFieldInput,
                                                        email: emailFieldInput,
                                                        rights: selectedRights)
                        }
                    }
                    
                    self.presentation.wrappedValue.dismiss()
                }
            } label: {
                Text(isNewUser ? "Add user" : "Edit user")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(Color(0x1d3557))
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        .navigationTitle(isNewUser ? "Add user" : "Edit user")
    }

    
    func loadMail() {
        self.nameFieldInput = user?.name ?? ""
        self.emailFieldInput = user?.email ?? ""
    }

}
