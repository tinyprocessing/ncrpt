//
//  ContentView.swift
//  EncryptFile
//
//  Created by Michael Safir on 25.10.2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var localFiles: LocalFileEngine = LocalFileEngine()
    
    var body: some View {
        VStack{
            HStack{
                Text("Encrypt")
                    .font(.largeTitle)
                Spacer()
                Button(action: {
                    let polygone = Polygone()
                    polygone.fileEncyptionTest()
                }, label: {
                    Image(systemName: "lock")
                        .font(.system(size: 24))
                        .foregroundColor(Color.black)
                })
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            VStack{
                ScrollView(.vertical, showsIndicators: false){
                    ForEach(self.localFiles.files, id:\.self) { file in
                        HStack(spacing: 15){
                            HStack(spacing: 5){
                                Text("\(file.name)")
                            }
                            Spacer()
                            
                            Button(action: {
                                share(items: [file.url!])
                            }, label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.black)
                            })
                            
                            Button(action: {
                                do {
                                    try FileManager.default.removeItem(atPath: (file.url?.path())!)
                                    self.localFiles.getLocalFiles()
                                } catch {
                                    print("Could not delete file, probably read-only filesystem")
                                }
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
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .frame(height: 200)
            }
            Spacer()
            Button(action: {
                let localFilesEngine = LocalFileEngine()
                localFilesEngine.getLocalFiles()
            }, label: {
                Text("Open File")
                    .padding(.horizontal, 55)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .cornerRadius(8.0)
                    .foregroundColor(Color.white)
            })
        }.onAppear{
            self.localFiles.getLocalFiles()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

@discardableResult
func share(
    items: [Any],
    excludedActivityTypes: [UIActivity.ActivityType]? = nil
) -> Bool {
    guard let source = UIApplication.shared.windows.last?.rootViewController else {
        return false
    }
    let vc = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil
    )
    vc.excludedActivityTypes = excludedActivityTypes
    vc.popoverPresentationController?.sourceView = source.view
    source.present(vc, animated: true)
    return true
}

