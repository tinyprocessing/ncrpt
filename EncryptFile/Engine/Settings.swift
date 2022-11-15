//
//  Settings.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import Foundation
import UIKit

let settings : Settings = Settings()

class Settings: ObservableObject, Identifiable {
    let id = 0
    
    static let shared = Settings()
    
    var max_log : Int = 15 // Mb
    var log_time_expire : Int = 30 // Days
    var log_allow : Bool = true
    
    var email : String = "help@ncrpt.io"
    
    var allowDebug : Bool = true
     
    func cleanLogs(){
        
        var cacheURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.absoluteString
        cacheURL += "/\(Bundle.main.bundleIdentifier!)/logs"
        cacheURL = cacheURL.replacingOccurrences(of: "file://", with: "")
        
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at:  URL(fileURLWithPath: cacheURL), includingPropertiesForKeys: nil, options: [])
            
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                }
                catch let error as NSError {
                    log.debug(module: "Settings", type: #function, object: "Something went wrong: \(error)")
                }
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }

    
    func alert(title: String, message: String, buttonName: String = "ok"){
        UIApplication.shared.windows.first?.rootViewController?.present(alertView(title: title, message: message, buttonName: buttonName), animated: true)
    }

    private func alertView(title: String, message: String, buttonName: String = "ok") -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        alert.view.tintColor = .white
        
        let okAction = UIAlertAction (title: buttonName, style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okAction)
        
        return alert
        
    }

    
}
