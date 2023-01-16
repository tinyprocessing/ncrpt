//
//  ScreenMonitor.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import Foundation
import SwiftUI
import EndpointSecurity


public class PrivacyMonitor: ObservableObject, Identifiable {
    public var id: Int = 0
    
    @Published var scene : String = "background"
    @Published var hide : Bool = false
    
    static let shared = PrivacyMonitor()

    var timer : Timer = Timer()


    @objc func getCurrentProcess(){
        DispatchQueue.global(qos: .userInitiated).async {
            let result = shell(" ps aux | grep -E 'zoom.us*|Skype*|AnnotationKit*|screen*'")
            let myStrings = result.components(separatedBy: .newlines)
            var state : Bool = false
            for string in myStrings {
                var name = string.slice(from: "Applications/", to: ".app/") ?? ""
                if (name == ""){
                    name = string.slice(from: "vices/", to: ".app") ?? ""
                }
                
                if (name == ""){
                    name = string.slice(from: "works/", to: ".f") ?? ""
                }
                
                if (name != ""){
                    if (name == "AnnotationKit" || name == "screencaptureui" || name == "screencapture"){
                        state = true
                        /* experimental feature */
                        if (name == "screencaptureui"){
//                            let killResult = shell(" killall screencaptureui")
                        }
                    }
                }
            }
            
            
            DispatchQueue.main.async {
                if (self.scene == "active"){
                    withAnimation{
                        self.hide = state
                    }
                }
            }
        }
    }
    
    func start(){
        DispatchQueue.global(qos: .userInitiated).async {
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.getCurrentProcess), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer, forMode: .common)
            RunLoop.current.run()
        }
    }
}


@discardableResult
func shell(_ args: String) -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.arguments = ["-c", args]
    do {
        try task.run()
    }catch{
//        log.debug(module: "IRM", type: #function, object: error.localizedDescription)
    }
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    if (output.count > 0){
//        TODO: ouput resolve
    }

    return output
}
