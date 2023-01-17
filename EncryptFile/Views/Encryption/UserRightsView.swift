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
    @State var nameFieldInput = ""
    @State var emailFieldInput = ""
    @State var selectedRights = Set<String>()
    
    @State var chosenPermission = ""
    
    var body: some View {
        
        
        ZStack(alignment: .bottom){
            
            ScrollView(.vertical, showsIndicators: false){
                VStack(alignment: .leading, spacing: 15){
                    VStack(alignment: .leading, spacing: 15){
                        HStack{
                            Text("User credentials")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color.init(hex: "21205A"))
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading) {
                            if isNewUser {
                                TextField("Type name", text: $nameFieldInput)
                                    .modifier(NCRPTTextMedium(size: 14))
                                    .frame(height: 30)
                                Divider()
                                TextField("Type email", text: $emailFieldInput)
                                    .modifier(NCRPTTextMedium(size: 14))
                                    .frame(height: 30)
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
                            
                        }.padding(.horizontal)
                        
                        HStack{
                            Text("User permissions")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color.init(hex: "21205A"))
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ForEach(vm.permissionSet, id: \.self) { item in
                            HStack {
                                Text("\(item)")
                                    .foregroundColor(.black)
                                    .modifier(NCRPTTextMedium(size: 14))
                                Spacer()
                                Image(systemName: selectedRights.contains(item) ? "checkmark.square" : "square")
                                    .foregroundColor(selectedRights.contains(item) ? Color.init(hex: "28B463") : .secondary)
                            }
                            .padding(.horizontal)
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
                            Divider()
                                .padding(.horizontal)
                            
                        }
                    }
                }
            }
            
            Button {
                if !emailFieldInput.isEmpty {
                    if isNewUser {
                        //add new user
                        vm.addNewUser(User(name: nameFieldInput,
                                           email: emailFieldInput,
                                           rights: selectedRights),
                                      new: true)
                    } else {
                        //edit user
                        vm.addNewUser(User(id: user!.id,
                                           name: nameFieldInput,
                                           email: emailFieldInput,
                                           rights: selectedRights))
                    }
                    
                    self.presentation.wrappedValue.dismiss()
                }
            } label: {
                HStack {
                    Spacer()
                    Text(isNewUser ? "Create user" : "Edit user")
                        .modifier(NCRPTTextMedium(size: 16))
                        .padding(.horizontal, 55)
                        .padding(.vertical, 10)
                        .background(Color.init(hex: "4378DB"))
                        .cornerRadius(8.0)
                        .foregroundColor(Color.white)
                    Spacer()
                }
            }
            
        }
        .navigationTitle("create user")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    
    func loadMail() {
        self.nameFieldInput = user?.name ?? ""
        self.emailFieldInput = user?.email ?? ""
    }
    
}
