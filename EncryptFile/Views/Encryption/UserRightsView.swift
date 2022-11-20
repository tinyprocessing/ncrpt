//
//  UserRightsView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 07.11.2022.
//

import SwiftUI

struct UserRightsView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var vm: ProtectViewModel
    @State var user: User?
    @State var isNewUser = false
    @State var emailFieldInput = ""
    @State var selectedRights = Set<String>()
    
    @State var chosenPermission = ""

    var body: some View {
        
        Form {
            //header
            Section(){
                VStack(alignment: .leading) {
                    if isNewUser {
                        TextField("Type email", text: $emailFieldInput)
                            .frame(height: 30)
                            .padding(.horizontal, 10)
                    } else {
                        TextField("", text: Binding<String>(
                            get: { self.emailFieldInput },
                            set: {
                                self.emailFieldInput = $0
                                self.user?.email = self.emailFieldInput
                        })).onAppear(perform: loadMail)
                            .frame(height: 30)
                            .padding(.horizontal, 10)
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
            
            //MARK: safe/edit user button
            Button {
                if !emailFieldInput.isEmpty {
                    if isNewUser {
                        //add new user
                        vm.recentUsers.append(User(email: emailFieldInput, rights: selectedRights))
                    } else {
                        //edit user
                        if let inx = vm.recentUsers.firstIndex(where: { $0.id == user?.id }) {
                            vm.recentUsers[inx] = User(email: emailFieldInput, rights: selectedRights)
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
        self.emailFieldInput = user?.email ?? ""
    }

}
