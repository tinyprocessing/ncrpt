//
//  Log.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import Foundation

public var log: Log = Log()

public class Log: ObservableObject, Identifiable, TextOutputStream {
    public var id: Int = 0
    
    func debug(module: String = "NCRPT", type: String,  object: Any) {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.locale = Locale.current
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date_to_print = dateFormatterGet.string(from: Date())
        
        if (true){
            print(date_to_print, "[NCRPT] [\(module)]", type, ":", object, to: &log)
        }
        print(date_to_print, "[NCRPT] [\(module)]", type, ":", object)
    }
    
    public func write(_ string: String) {
        
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path += "/\(Bundle.main.bundleIdentifier!)/logs"
        
        let url = URL(fileURLWithPath: path)
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
        
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.locale = Locale.current
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
            let fm = FileManager.default
            let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(Bundle.main.bundleIdentifier!)/logs/ncrpt_\(dateFormatterGet.string(from: Date())).log")
            
            if let handle = try? FileHandle(forWritingTo: log) {
                handle.seekToEndOfFile()
                handle.write(string.data(using: .utf8)!)
                handle.closeFile()
            } else {
                try? string.data(using: .utf8)?.write(to: log)
            }
    }

}
