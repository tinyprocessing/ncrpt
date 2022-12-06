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
    
 
    @State var chosenPermission = ""

    var body: some View {
        
        Form {
            //header
            Section(header: Text("Name of Template")){
                VStack(alignment: .leading) {
                    if isNewTemplate {
                        TextField("Type new template name", text: $templateFieldInput)
                            .frame(height: 30)
                            .padding(.horizontal, 10)
                    } else {
                        TextField("", text: Binding<String>(
                            get: { self.templateFieldInput },
                            set: {
                                self.templateFieldInput = $0
                                self.template?.name = self.templateFieldInput
                        })).onAppear(perform: loadTemplate)
                            .frame(height: 30)
                            .padding(.horizontal, 10)
                    }
                    
                }
                
            }
            //User list
            Section(header: Text("User list")){
                ForEach(template?.users ?? [], id: \.self) { item in
                    Text(item)
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
                if !templateFieldInput.isEmpty {
                    if isNewTemplate {
                        //add new template
                        vm.templates.append(Template(name: templateFieldInput, rights: selectedRights))
                    } else {
                        //edit template
                        if let inx = vm.templates.firstIndex(where: { $0.id == template?.id }) {
                            vm.templates[inx] = Template(name: templateFieldInput, rights: selectedRights)
                        }
                    }
                    
                    self.presentation.wrappedValue.dismiss()
                }
            } label: {
                Text(isNewTemplate ? "Add template" : "Edit template")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(Color(0x1d3557))
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        .navigationTitle(isNewTemplate ? "New template" : "Edit template")
    }
    
    
    func loadTemplate() {
        self.templateFieldInput = template?.name ?? ""
    }

}

struct TemplateView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateView(vm: ProtectViewModel())
    }
}
