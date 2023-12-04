//
//  APINotifications.swift
//  EncryptFile
//
//  Created by Michael Safir on 17.12.2022.
//

import Foundation
import Alamofire
import SwiftyRSA
import SwiftyJSON

class APINotifications: ObservableObject, Identifiable  {
    
    struct Notification : Identifiable, Hashable {
        var id : Int = 0
        var title : String
        var text : String
        var link : String
        var time : String
    }
    
    func getAll(completion: @escaping (_ all: [APINotifications.Notification], _ success:Bool) -> Void){
        AF.request("https://api.ncrpt.io/notifications.php", method: .get, encoding: URLEncoding.default).responseJSON { [self] (response) in
            if (response.value != nil) {
                let json = JSON(response.value!)
                var notifications : [APINotifications.Notification] = []
                json.arrayValue.forEach { item in
                    let title = item["title"].stringValue
                    let text = item["text"].stringValue
                    let link = item["link"].stringValue
                    let time = item["time"].stringValue
                    notifications.append(APINotifications.Notification(title: title, text: text, link: link, time: time))
                }
                completion(notifications, true)
            }else{
                completion([], false)
            }
        }
    }
}
