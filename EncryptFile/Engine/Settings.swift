//
//  Settings.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import Foundation
import SwiftUI

let settings : Settings = Settings()

class Settings: ObservableObject, Identifiable {
    let id = 0
    
    static let shared = Settings()
    
    var max_log : Int = 15 // Mb
    var log_time_expire : Int = 30 // Days
    var log_allow : Bool = true
    
    var email : String = "help@ncrpt.io"
    var server : String = "https://secure.ncrpt.io"
    
    var allowDebug : Bool = true
    
    func logout(){
        let domain = Bundle.main.bundleIdentifier!
        
        UserDefaults.standard.reset()
        
        let keychain = Keychain()
        keychain.helper.deleteKeyChain()
        
        cleanCache()
        
        DispatchQueue.main.async {
            withAnimation{
                NCRPTWatchSDK.shared.ui = .loading
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation{
                NCRPTWatchSDK.shared.ui = .auth
            }
        }
    }
    
    func shareLogs() {
        let fileManager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathWithLogs = path + "/\(Bundle.main.bundleIdentifier!)/logs"
        let urlFolder = URL(fileURLWithPath: pathWithLogs)
        do {
            try FileManager.default.createDirectory(at: urlFolder, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = (dateFormatter.string(from: Date()))
        
        let fileLogsZIP = path + "/\(Bundle.main.bundleIdentifier!)" + "/ncrpt_\(currentDateString)_log.zip"
        let urlLogsZIP = URL(fileURLWithPath: fileLogsZIP)

        do {
            try fileManager.zipItem(at: urlFolder, to: urlLogsZIP)
            share(items: [urlLogsZIP])
            log.debug(module: "Settings", type: #function, object: "Share url: \(fileLogsZIP)")
        }catch{
            log.debug(module: "Settings", type: #function, object: "Error: \(error)")
            do {
                try FileManager.default.removeItem(atPath: (urlLogsZIP.path().removingPercentEncoding)!)
                try fileManager.zipItem(at: urlFolder, to: urlLogsZIP)
                share(items: [urlLogsZIP])
                log.debug(module: "Settings", type: #function, object: "Share url: \(fileLogsZIP)")
            } catch {
                log.debug(module: "Settings", type: #function, object: "Could not delete file, probably read-only filesystem")
            }
        }
    }
    
    func cleanCache(){
        
        do {
            // Get the document directory url
            let cachesDirectory = try FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            let documentDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: cachesDirectory,
                includingPropertiesForKeys: nil
            )
            
            directoryContents.forEach { item in
                log.debug(module: "Settings", type: #function, object: "clean - \(item.localizedName ?? "*filename*")")
                let name = item.localizedName ?? ""
                if name.contains("ncrpt.io.iosviewer") {
                    do {
                        let LogsDirectory = documentDirectory.appendingPathComponent("ncrpt.io.iosviewer/")
                        let LogsDirectoryContents = try FileManager.default.contentsOfDirectory(
                            at: LogsDirectory,
                            includingPropertiesForKeys: nil
                        )
                        LogsDirectoryContents.forEach { itemInLogs in
                            if (itemInLogs.localizedName ?? "").contains(".zip"){
                                log.debug(module: "Settings", type: #function, object: "clean - \(itemInLogs.localizedName ?? "*filename*")")
                                do {
                                    try FileManager.default.removeItem(atPath: (itemInLogs.path().removingPercentEncoding)!)
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    }catch{
                        log.debug(module: "Settings", type: #function, object: "Error - \(error)")
                    }
                }
                if item.typeIdentifier == "public.folder" && !item.isNCRPT && !name.contains("ncrpt.io.iosviewer") {
                    DispatchQueue.main.asyncAfter(deadline: .now()){
                        do {
                            try FileManager.default.removeItem(atPath: (item.path().removingPercentEncoding)!)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try FileManager.default.removeItem(atPath: fileUrl.path)
            }
        } catch {
            //catch the error somehow
        }
    }
    
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
        log.debug(module: "Settings", type: #function, object: "Alert: \(title) - \(message)")
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.rootViewController?.present(self.alertView(title: title, message: message, buttonName: buttonName), animated: true)
        }
    }
    
    private func alertView(title: String, message: String, buttonName: String = "ok") -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .light
        alert.view.tintColor = .black
        
        let okAction = UIAlertAction (title: buttonName, style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okAction)
        
        return alert
    }
    
    func alertViewWithCompletion(title: String, message: String, buttonName: String = "ok", completion: @escaping (_ success:Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .light
        alert.view.tintColor = .black
        
        let yesAction = UIAlertAction (title: "Yes", style: UIAlertAction.Style.destructive, handler: { _ in
            completion(true)
        })
        let noAction = UIAlertAction (title: "No", style: UIAlertAction.Style.cancel, handler: { _ in
            completion(false)
        })
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
        
    }
    
    
}
