//
//  ProtectionTemplateView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 03.11.2022.
//

import SwiftUI

struct ProtectionTemplateView: View {
    @Binding var isByTemplate: Bool
    @Binding var isCustomGeneral: Bool

    @State var chosenTemplate = "Choose template"
    let listTemplates = ["For all employers", "Accountants", "Managers"]

    var body: some View {
        Section {
            HStack {
                Image(systemName: isByTemplate ? "checkmark.square" : "square")
                    .foregroundColor(
                        isByTemplate ? .green : .secondary
                    )
                Text("Protect by template")
            }.onTapGesture {
                withAnimation {
                    isByTemplate.toggle()
                    if isCustomGeneral {
                        isCustomGeneral = false
                    }
                }

            }
            if isByTemplate {
                HStack {
                    Text(chosenTemplate).foregroundColor(.secondary)
                    Spacer()
                    Menu {
                        ForEach(listTemplates, id: \.self) {
                            temp in
                            Button {
                                chosenTemplate =
                                    temp
                            } label: {
                                Text(
                                    temp
                                )
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(
                                Color(
                                    0x1d3557
                                )
                            )
                            .frame(height: 45)
                    }
                }
                .frame(height: 50)

            }

        }
    }
}

struct ProtectTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        ProtectionTemplateView(isByTemplate: .constant(true), isCustomGeneral: .constant(true))
    }
}
