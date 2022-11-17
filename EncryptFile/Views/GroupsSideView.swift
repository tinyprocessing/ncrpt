//
//  GroupsSideView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 28.10.2022.
//


import SwiftUI

struct GroupsSideView: View {
    @ObservedObject var viewModel: GroupViewModel
    @State var email : String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Image("NCRPT")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100, alignment: .center)
                .padding()
            
            
            Text(self.email.lowercased())
                .foregroundColor(.white)
                .modifier(NCRPTTextRegular(size: 16))
                .padding(.horizontal, 15)
                .underline()
            
            Spacer()
            
            
            VStack(alignment: .leading, spacing: 20){
                
                NavigationLink(destination: Text("Templates"), label: {
                    HStack(spacing: 10){
                        Image(systemName: "person.and.background.dotted")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 30)
                        Text("Templates")
                            .foregroundColor(.white)
                            .modifier(NCRPTTextRegular(size: 16))
                    }
                })
                
                NavigationLink(destination: Text("Notifications"), label: {
                    HStack(spacing: 10){
                        Image(systemName: "bell")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 30)
                        Text("Notifications")
                            .foregroundColor(.white)
                            .modifier(NCRPTTextRegular(size: 16))
                    }
                })
                
                NavigationLink(destination: Text("Settings"), label: {
                    HStack(spacing: 10){
                        Image(systemName: "gear")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 30)
                        Text("Settings")
                            .foregroundColor(.white)
                            .modifier(NCRPTTextRegular(size: 16))
                    }
                })
                
                NavigationLink(destination: Text("Support"), label: {
                    HStack(spacing: 10){
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 30)
                        Text("Support")
                            .foregroundColor(.white)
                            .modifier(NCRPTTextRegular(size: 16))
                    }
                })
                
                VStack(alignment: .leading, spacing: 20){
                    NavigationLink(destination: Text("License"), label: {
                        Text("License")
                            .foregroundColor(.white)
                            .modifier(NCRPTTextRegular(size: 16))
                    })
                    
                    NavigationLink(destination: Text("Logging"), label: {
                        Text("Logging")
                            .foregroundColor(.white)
                            .modifier(NCRPTTextRegular(size: 16))
                    })
                    
                }.padding(.top, 30)
                
                
            }
            .padding(.vertical, 35)
            .padding(.horizontal, 15)
            
            Spacer()
            
            Button(action: {
                
            }, label: {
                HStack(spacing: 10){
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 30)
                    
                    Text("Log out")
                        .foregroundColor(.white)
                        .modifier(NCRPTTextRegular(size: 16))
                }
            })
            .padding(.vertical, 35)
            .padding(.horizontal, 15)
            
        }.onAppear{
            DispatchQueue.global(qos: .userInitiated).async {
                let certification = Certification()
                certification.getCertificate()
                DispatchQueue.main.async {
                    self.email = certification.certificate.email ?? ""
                }
            }
        }
    }
}

struct GroupsSideView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsSideView(viewModel: GroupViewModel())
    }
}
