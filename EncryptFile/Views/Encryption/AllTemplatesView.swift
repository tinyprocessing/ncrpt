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
        Form {
            Section(header: Text("Templates")) {
                ForEach(pvm.templates) { templ in
                    HStack{
                        Text(templ.name)
                        Spacer()
                        Button {
                            showEditTemplate.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .foregroundColor(Color(0x1d3557))
                        .overlay(
                            NavigationLink(
                                destination: { TemplateView(vm: pvm,
                                                            template: templ,
                                                            selectedRights: templ.rights,
                                                            usersInTamplate: Array(templ.users)) },
                                label: { EmptyView() }
                            ).opacity(0)
                        )
                        
                    }
                    
                }
                .onDelete(perform: deleteTemplate)
                
                Button {
                    showNewTemplate.toggle()
                } label: {
                    HStack{
                        Spacer()
                        Image(systemName: "plus.circle")
                        Text("Add new template")
                        Spacer()
                    }.foregroundColor(Color(0x1d3557))
                }
                .overlay(
                    NavigationLink(
                        destination: { TemplateView(vm: pvm, isNewTemplate: true) },
                        label: { EmptyView() }
                    ).opacity(0)
                )
                
            }
        }
    }
    
    func deleteTemplate(at offsets: IndexSet) {
        pvm.removeTemplate(at: offsets)
    }
}

struct AllTemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        AllTemplatesView(pvm: ProtectViewModel())
    }
}
