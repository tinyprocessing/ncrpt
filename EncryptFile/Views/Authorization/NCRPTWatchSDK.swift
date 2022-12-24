//
//  AuthorizationEngine.swift
//  EncryptFile
//
//  Created by Michael Safir on 24.12.2022.
//

import Foundation
import SwiftUI
import UIKit
import Combine

class NCRPTWatchSDK: NSObject, ObservableObject, Identifiable {
    
    
    static let shared = NCRPTWatchSDK()
    @Published var ui : UI = .loading
    @Published var authorization : NCRPTAuthSDK = NCRPTAuthSDK.shared
    @Published var authorizationStatus : Bool = false
    
    @Published var needBlur : Bool = false
    
    var visualEffectView = UIVisualEffectView()
    
    var callback: (( _ success:Bool) -> Void)?
    
    var window : UIWindow? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    
    func isAuthorized() -> Bool{
        return self.authorizationStatus
    }

    enum UI {
        case loading
        case cache
        case pin
        case pinCreate
        case auth
        case ready
        case error
    }
 
    func setupSecureView(){
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.needBlur = false
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.needBlur = false
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main) { [self] (notification) in
            if (self.ui == .pinCreate){
                self.ui = .auth
                Settings.shared.logout()
            }
//            withAnimation{
                needBlur = true
//            }
        }
    }
    
    
    /// Запуск SDK
    /// - Parameter completion:
    public func start(completion: @escaping (_ success:Bool, _ error: NSError?) -> Void){
        
        self.authorizationStatus = false
        
    }
    
}
