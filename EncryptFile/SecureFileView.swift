import SwiftUI

struct SecureFileView: View {
    @ObservedObject var pvm: ProtectViewModel
    @State var files: [fileItem] = []
    @State private var isImporting = false
    @State private var presentAddUsers = false
    @State private var username = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showNewUser = false
    @State private var showEditUser = false
    @State private var showNewTemplate = false
    @State private var showEditTemplate = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Protect with template")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color(hex: "21205A"))
                            Spacer()

                            NavigationLink(
                                destination: { TemplateView(vm: pvm, isNewTemplate: true) },
                                label: {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(Color.black)
                                }
                            )
                        }
                        .padding(.horizontal)

                        if pvm.templates.isEmpty {
                            HStack {
                                Spacer()
                                Text("no templates in list")
                                Spacer()
                            }.padding()
                        }

                        ForEach(pvm.templates) { templateItem in

                            NavigationLink(
                                destination: { TemplateView(vm: pvm,
                                                            template: templateItem,
                                                            selectedRights: templateItem.rights,
                                                            usersInTamplate: Array(templateItem.users)) },
                                label: {
                                    HStack {
                                        Image(systemName: pvm.isCurTemplate(templateItem) ? "checkmark.square" : "square")
                                            .foregroundColor(pvm.isCurTemplate(templateItem) ? Color(hex: "28B463") : .secondary)
                                            .onTapGesture {
                                                pvm.selectTemplate(templateItem.id)
                                            }

                                        VStack(alignment: .leading) {
                                            Text(templateItem.name)
                                                .modifier(NCRPTTextMedium(size: 14))
                                                .foregroundColor(.black)
                                                .font(.system(size: 10))
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }.padding(.vertical, 5)
                                }
                            )
                            .padding(.horizontal)
                            .background(Color.white)
                        }
                    }
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Select users")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color(hex: "21205A"))
                            Spacer()

                            NavigationLink(
                                destination: { UserRightsView(vm: pvm, isNewUser: true) },
                                label: {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(Color.black)
                                }
                            )
                        }
                        .padding(.horizontal)

                        if pvm.recentUsers.isEmpty {
                            HStack {
                                Spacer()
                                Text("no recent users")
                                Spacer()
                            }.padding()
                        }

                        ForEach(pvm.recentUsers) { user in

                            NavigationLink(
                                destination: { UserRightsView(vm: pvm, user: user, selectedRights: user.rights) },
                                label: {
                                    HStack {
                                        Image(systemName: pvm.isSelUser(user) ? "checkmark.square" : "square")
                                            .foregroundColor(pvm.isSelUser(user) ? Color(hex: "28B463") : .secondary)
                                            .onTapGesture {
                                                pvm.addSelectUser(user)
                                            }
                                        VStack(alignment: .leading) {
                                            Text(user.email)
                                                .modifier(NCRPTTextMedium(size: 14))
                                            Text(user.allRights)
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
                        }
                    }
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Select files")
                                .modifier(NCRPTTextSemibold(size: 18))
                                .foregroundColor(Color(hex: "21205A"))
                            Spacer()
                            Button {
                                isImporting = true
                            } label: {
                                Image(systemName: "plus.circle")
                            }
                        }
                        .padding(.horizontal)

                        ForEach(pvm.chosenFiles, id: \.self) { file in
                            HStack {
                                Text("\(file.name)")
                                    .modifier(NCRPTTextMedium(size: 14))
                                Spacer()
                                Text("\(file.size)")
                                    .modifier(NCRPTTextMedium(size: 14))
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 10))
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                            .background(Color.white)
                        }
                    }
                }
            }

            Button(action: {
                let template = pvm.templates.first { $0.id == pvm.selectedTemplated }
                if template != nil {
                    template!.users.forEach { user in
                        pvm.selectedResentUsers.append(user)
                    }
                }
                // Check chosen files
                let polygone = Polygone()
                if !pvm.chosenFiles.isEmpty {
                    polygone.encryptFile((pvm.chosenFiles.first?.url)!, users: pvm.selectedResentUsers) { success in
                        print(success)
                        if success {
                            Settings.shared.alert(title: "Success", message: "Your files are protected, you can find them on home page")
                            self.pvm.clear()
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            Settings.shared.alert(title: "Error", message: "File is not protected, try again later")
                        }
                    }
                }
            }, label: {
                HStack {
                    Spacer()
                    Text("protect file")
                        .padding(.horizontal, 55)
                        .padding(.vertical, 10)
                        .background(!pvm.chosenFiles
                            .isEmpty && (
                                !pvm.selectedResentUsers.isEmpty || pvm.templates.first { $0.id == pvm.selectedTemplated } != nil
                            ) ?
                            Color(hex: "4378DB") : Color(hex: "4378DB").opacity(0.1))
                        .cornerRadius(8.0)
                        .foregroundColor(Color.white)
                    Spacer()
                }

            })
        }
        .onAppear {
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
        .navigationTitle("protection")
        .navigationBarTitleDisplayMode(.inline)
    }

    func deleteUser(at offsets: IndexSet) {
        pvm.removeUser(at: offsets)
    }

    func deleteFile(at offsets: IndexSet) {
        pvm.chosenFiles.remove(atOffsets: offsets)
    }
}

struct SecureFileView_Previews: PreviewProvider {
    static var previews: some View {
        SecureFileView(pvm: ProtectViewModel())
    }
}
