//
//  AllTemplatesView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 20.11.2022.
//

import SwiftUI

struct AllTemplatesView: View {
    @ObservedObject var pvm: ProtectViewModel
    @State private var showNewTemplate = false
    @State private var showEditTemplate = false

    var body: some View {

        ZStack(alignment: .bottom) {

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("All Templates")
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

                        if pvm.templates.count == 0 {
                            HStack {
                                Spacer()
                                Text(
                                    "no templates in list"
                                )
                                Spacer()
                            }.padding()
                        }

                        ForEach(pvm.templates) {
                            templateItem in

                            NavigationLink(
                                destination: {
                                    TemplateView(
                                        vm:
                                            pvm,
                                        template:
                                            templateItem,
                                        selectedRights:
                                            templateItem
                                            .rights,
                                        usersInTamplate:
                                            Array(
                                                templateItem
                                                    .users
                                            )
                                    )
                                },
                                label: {
                                    HStack {
                                        VStack(
                                            alignment:
                                                .leading
                                        ) {
                                            Text(
                                                templateItem
                                                    .name
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
                                        }
                                        Spacer()
                                        Image(
                                            systemName:
                                                "chevron.right"
                                        )
                                    }
                                    .padding(
                                        .vertical,
                                        5
                                    )
                                }
                            )
                            .padding(.horizontal)
                            .background(
                                Color
                                    .white
                            )
                            .contextMenu {
                                Button(
                                    role:
                                        .destructive,
                                    action: {
                                        var tmpArray: [Template] =
                                            []
                                        self
                                            .pvm
                                            .templates
                                            .forEach {
                                                userItem
                                                in
                                                if userItem
                                                    .id
                                                    != templateItem
                                                    .id
                                                {
                                                    tmpArray
                                                        .append(
                                                            userItem
                                                        )
                                                }
                                            }
                                        self
                                            .pvm
                                            .templates =
                                            tmpArray
                                        self
                                            .pvm
                                            .updateTemplates()
                                    }
                                ) {
                                    Label(
                                        "Delete",
                                        systemImage:
                                            "trash"
                                    )
                                    .foregroundColor(
                                        .red
                                    )
                                }
                            }
                        }
                    }
                }
            }

            NavigationLink(
                destination: { TemplateView(vm: pvm, isNewTemplate: true) },
                label: {
                    HStack {
                        Spacer()
                        Text("Add new template")
                            .modifier(
                                NCRPTTextMedium(
                                    size:
                                        16
                                )
                            )
                            .padding(
                                .horizontal,
                                55
                            )
                            .padding(
                                .vertical,
                                10
                            )
                            .background(
                                Color
                                    .init(
                                        hex:
                                            "4378DB"
                                    )
                            )
                            .cornerRadius(8.0)
                            .foregroundColor(
                                Color
                                    .white
                            )
                        Spacer()
                    }
                }
            )
        }
        .navigationTitle("templates")
        .navigationBarTitleDisplayMode(.inline)

    }
}

struct AllTemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        AllTemplatesView(pvm: ProtectViewModel())
    }
}
