//
//  SecureFileView.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 16.11.2022.
//

import SwiftUI


struct userItem : Identifiable, Hashable {
    var id: Int = 0
    var email : String = ""
    var rights : String = ""
}


struct SecureFileView: View {
    
    @State var files : [fileItem] = []
    @State var users : [userItem] = []
    @State private var isImporting: Bool = false
    @State private var presentAddUsers = false
    @State private var username: String = ""

    var body: some View {
        VStack{
            ZStack(alignment: .bottom){
                ScrollView(.vertical, showsIndicators: false) {
                    Button(action: {
                        self.isImporting.toggle()
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundColor(.black)
                                .font(.system(size: 22, weight: .light, design: .rounded))
                                .padding(.horizontal, 10)
                            Text("Select file")
                            Spacer()
                        }
                        .frame(height: 50, alignment: .leading)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                        .padding()
                    })
                    
                    VStack{
                        if self.files.count > 0 {
                            HStack{
                                Text("Selected files:")
                                Spacer()
                            }
                        }
                        ForEach(self.files, id:\.self) { file in
                            HStack(spacing: 15){
                                HStack(spacing: 5){
                                    Image("file")
                                        .resizable()
                                        .frame(width: 20, height: 20, alignment: .center)
                                    Text("\(file.name.lowercased())")
                                }
                                Spacer()
                                
                                Button(action: {
                                    var tmp : [fileItem] = []
                                    self.files.forEach { arrayFile in
                                        if arrayFile.url != file.url{
                                            tmp.append(arrayFile)
                                        }
                                    }
                                    self.files = tmp
                                }, label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color.red)
                                })
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }.padding(.horizontal)
                    
                    VStack{
                        HStack{
                            Text("Select users:")
                            Spacer()
                        }
                        
                        Button(action: {
                            self.presentAddUsers.toggle()
                        }, label: {
                            HStack(spacing: 0) {
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.black)
                                    .font(.system(size: 22, weight: .light, design: .rounded))
                                    .padding(.horizontal, 10)
                                Text("add users")
                                Spacer()
                            }
                            .frame(height: 50, alignment: .leading)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                        })
                        .alert("New User", isPresented: $presentAddUsers, actions: {
                            TextField("Email", text: $username)
                                .textCase(.lowercase)
                                .autocorrectionDisabled()
                            Button("Add", action: {
                                self.users.append(userItem(id: self.users.count+1, email: self.username, rights: "VIEW"))
                                self.username = ""
                            })
                            Button("Cancel", role: .cancel, action: {})
                        }, message: {
                            Text("Please enter your username and password.")
                        })
                        
                        ForEach(self.users, id:\.self) { user in
                            HStack(spacing: 15){
                                HStack(spacing: 5){
                                    Image(systemName: "person")
                                        .frame(width: 20, height: 20, alignment: .center)
                                    Text("\(user.email)")
                                }
                                Spacer()
                                
                                Button(action: {
                                    var tmp : [userItem] = []
                                    self.users.forEach { arrayUser in
                                        if arrayUser.email != user.email{
                                            tmp.append(arrayUser)
                                        }
                                    }
                                    self.users = tmp
                                }, label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color.red)
                                })
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                    }.padding()
                    
                }
                
                
                Button(action: {
                    let polygone = Polygone()
                    if self.files.count > 0 {
                        polygone.encryptFile((self.files.first?.url)!, users: self.users) { success in
                            print(success)
                            Settings.shared.alert(title: "Success", message: "Your files are protected, you can find them on home page")
                        }
                    }
                }, label: {
                    Text("protect file")
                        .padding(.horizontal, 55)
                        .padding(.vertical, 10)
                        .background(self.files.count > 0 && self.users.count > 0 ? Color.black : Color.black.opacity(0.1))
                        .cornerRadius(8.0)
                        .foregroundColor(Color.white)
                })
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.pdf, .docx, .png, .jpg, .jpeg, .zip, .image, .tiff, .gif, .pptx, .xlsx, .plainText],
                allowsMultipleSelection: true
            ) { result in
                do {
                    guard let selected: [URL]? = try result.get() else { return }
                    if let files = selected {
                        files.forEach { file in
                            file.startAccessingSecurityScopedResource()
                            self.files.append(fileItem(id: 0, name: file.lastPathComponent, url: file, ext: file.pathExtension.lowercased()))
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
}

struct SecureFileView_Previews: PreviewProvider {
    static var previews: some View {
        SecureFileView()
    }
}
