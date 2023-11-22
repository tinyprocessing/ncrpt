//
//  TemplateUserView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 25.12.2022.
//

import SwiftUI

enum TextFieldType {
    case nameField, emailField
}

struct TemplateUserView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var vm: ProtectViewModel
    @State var user: User?
    @State var isNewUser = false
    @State var nameFieldInput = ""
    @State var emailFieldInput = ""
    @State var selectedRights = Set<String>()
    @Binding var usersInTamplate: [User]
    @State var contactsIsHidden = false
    @State var currentTextField = TextFieldType.nameField

    private var filteredContacts: [User] {
        if emailFieldInput.isEmpty && nameFieldInput.isEmpty {
            return []
        }
        else {
            switch currentTextField {
            case .nameField:
                return vm.contacts.filter {
                    $0.name.localizedCaseInsensitiveContains(
                        nameFieldInput
                    )
                }
            case .emailField:
                return vm.contacts.filter {
                    $0.email.localizedCaseInsensitiveContains(
                        emailFieldInput
                    )
                }
            }
        }
    }

    var body: some View {

        ZStack(alignment: .bottom) {

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text(
                                "User credentials"
                            )
                            .modifier(
                                NCRPTTextSemibold(
                                    size:
                                        18
                                )
                            )
                            .foregroundColor(
                                Color
                                    .init(
                                        hex:
                                            "21205A"
                                    )
                            )
                            Spacer()
                        }
                        .padding(.horizontal)

                        VStack(alignment: .leading) {
                            if isNewUser {
                                TextField(
                                    "Type name",
                                    text:
                                        $nameFieldInput,
                                    onEditingChanged: {
                                        changed
                                        in
                                        if changed {
                                            currentTextField =
                                                .nameField
                                        }
                                    }
                                )
                                .modifier(
                                    NCRPTTextMedium(
                                        size:
                                            14
                                    )
                                )
                                .frame(
                                    height:
                                        30
                                )
                                .onTapGesture {
                                    contactsIsHidden =
                                        false
                                }

                                Divider()
                                TextField(
                                    "Type email",
                                    text:
                                        $emailFieldInput,
                                    onEditingChanged: {
                                        changed
                                        in
                                        if changed {
                                            currentTextField =
                                                .emailField
                                        }
                                    }
                                )
                                .modifier(
                                    NCRPTTextMedium(
                                        size:
                                            14
                                    )
                                )
                                .frame(
                                    height:
                                        30
                                )
                                .onTapGesture {
                                    contactsIsHidden =
                                        false
                                }
                            }
                            else {
                                TextField(
                                    "",
                                    text:
                                        Binding<
                                            String
                                        >(
                                            get: {
                                                self
                                                    .nameFieldInput
                                            },
                                            set: {
                                                self
                                                    .nameFieldInput =
                                                    $0
                                                self
                                                    .user?
                                                    .name =
                                                    self
                                                    .nameFieldInput
                                            }
                                        )
                                )
                                .frame(
                                    height:
                                        30
                                )
                                Divider()
                                TextField(
                                    "",
                                    text:
                                        Binding<
                                            String
                                        >(
                                            get: {
                                                self
                                                    .emailFieldInput
                                            },
                                            set: {
                                                self
                                                    .emailFieldInput =
                                                    $0
                                                self
                                                    .user?
                                                    .email =
                                                    self
                                                    .emailFieldInput
                                            }
                                        )
                                )
                                .frame(
                                    height:
                                        30
                                )
                                .onAppear(
                                    perform:
                                        loadMail
                                )
                            }

                        }.padding(.horizontal)

                        HStack {
                            Text(
                                "User permissions"
                            )
                            .modifier(
                                NCRPTTextSemibold(
                                    size:
                                        18
                                )
                            )
                            .foregroundColor(
                                Color
                                    .init(
                                        hex:
                                            "21205A"
                                    )
                            )
                            Spacer()
                        }
                        .padding(.horizontal)

                        ForEach(
                            vm.permissionSet,
                            id: \.self
                        ) { item in
                            HStack {
                                Text(
                                    "\(item)"
                                )
                                .foregroundColor(
                                    .black
                                )
                                .modifier(
                                    NCRPTTextMedium(
                                        size:
                                            14
                                    )
                                )
                                Spacer()
                                Image(
                                    systemName:
                                        selectedRights
                                        .contains(
                                            item
                                        )
                                        ? "checkmark.square"
                                        : "square"
                                )
                                .foregroundColor(
                                    selectedRights
                                        .contains(
                                            item
                                        )
                                        ? Color
                                            .init(
                                                hex:
                                                    "28B463"
                                            )
                                        : .secondary
                                )
                            }
                            .padding(.horizontal)
                            .contentShape(
                                Rectangle()
                            )
                            .onTapGesture {
                                if selectedRights
                                    .contains(
                                        item
                                    )
                                {
                                    selectedRights
                                        .remove(
                                            item
                                        )
                                }
                                else {
                                    selectedRights
                                        .insert(
                                            item
                                        )
                                }
                                print(
                                    selectedRights
                                )
                            }
                            Divider()
                                .padding(
                                    .horizontal
                                )

                        }
                    }
                }
            }

            Button {
                if !emailFieldInput.isEmpty {
                    if isNewUser {
                        //add new user
                        usersInTamplate.append(
                            User(
                                name:
                                    nameFieldInput,
                                email:
                                    emailFieldInput,
                                rights:
                                    selectedRights
                            )
                        )
                    }
                    else {
                        if let inx =
                            usersInTamplate
                            .firstIndex(where: {
                                $0.id
                                    == user!
                                    .id
                            })
                        {
                            usersInTamplate[inx] =
                                User(
                                    id:
                                        user!
                                        .id,
                                    name:
                                        nameFieldInput,
                                    email:
                                        emailFieldInput,
                                    rights:
                                        selectedRights
                                )
                        }
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
                        .background(
                            Color.init(
                                hex:
                                    "4378DB"
                            )
                        )
                        .cornerRadius(8.0)
                        .foregroundColor(Color.white)
                    Spacer()
                }
            }
            .padding()
            .ignoresSafeArea(.keyboard, edges: .bottom)

            //MARK: contact helper view
            if !emailFieldInput.isEmpty || !nameFieldInput.isEmpty {
                if !contactsIsHidden {
                    ZStack {
                        List(filteredContacts) { user in
                            Text(
                                currentTextField
                                    == .nameField
                                    ? user
                                        .name
                                    : user
                                        .email
                            )
                            .modifier(
                                NCRPTTextMedium(
                                    size:
                                        14
                                )
                            )
                            .listRowBackground(
                                Color
                                    .clear
                            )
                            .onTapGesture {
                                nameFieldInput =
                                    user
                                    .name
                                emailFieldInput =
                                    user
                                    .email
                                contactsIsHidden =
                                    true
                                UIApplication
                                    .shared
                                    .dismissKeyboard()
                            }
                        }

                    }
                    .background(.ultraThinMaterial)
                    .frame(maxHeight: getHeightContacts())
                    .scrollDisabled(isScrollDisabled())
                    .listStyle(.plain)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }

            }

        }.navigationTitle(isNewUser ? "create user" : "edit user")

    }

    func loadMail() {
        self.nameFieldInput = user?.name ?? ""
        self.emailFieldInput = user?.email ?? ""
    }

    private func getHeightContacts() -> CGFloat {
        if filteredContacts.count >= 3 {
            return 132
        }
        else if filteredContacts.count == 2 {
            return 86
        }
        else if filteredContacts.count == 1 {
            return 42
        }
        else {
            return 0
        }
    }

    private func isScrollDisabled() -> Bool {
        return filteredContacts.count >= 3 ? false : true
    }
}

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
