//
//  File.swift
//
//
//  Created by Сафир Михаил Дмитриевич [B] on 15.03.2022.
//

import Foundation
import SwiftUI
// Создание pin-code для входа в и сохранение в кейчене
struct PinEntryView: View {
    
    var pinLimit: Int = 4
    var isError: Bool = false
    var canEdit: Bool = true
    @State var pinCode: String = ""
    @ObservedObject var api: NCRPTWatchSDK = NCRPTWatchSDK.shared
    @State var status: String = ""
    @State var attempts: Int = 1
    @State var attemptsRegistration: Int = 0
    @State var preCreatePIN : String = ""
    @State var pin: [String] = []
    
    var body: some View {
        VStack(spacing: 10){
            Image("NCRPTBlue")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 70, alignment: .center)
                .padding(.bottom, 20)
            
            Spacer()
            
            PinFieldView(pin: self.$pin)
            
            Spacer()
            
            if (self.api.ui == .pin){
                Button(action: {
                    NCRPTWatchSDK.shared.authorization.passwordRecover = true
                    withAnimation {
                        self.api.ui = .auth
                    }
                }, label: {
                    HStack{
                        Spacer()
                        Text("Forgot Pin?")
                            .padding(.vertical, 15)
                            .foregroundColor(Color.black)
                            .modifier(NCRPTTextMedium(size: 16))
                        
                        Spacer()
                    }
                })
            }
            Text("Version \((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!)")
                .foregroundColor(Color.gray.opacity(0.9))
                .modifier(NCRPTTextMedium(size: 16))
            
            
        }
        .padding([.vertical], 20)
        .onAppear {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
}

import LocalAuthentication


struct PinFieldView: View {
    
    @Binding var pin : [String]
    @ObservedObject var api: NCRPTWatchSDK = NCRPTWatchSDK.shared
    
    @State var attemptsRegistration: Bool = false
    @State var pinRepeat : [String] = []
    
    @State var wrongAttempt: Bool = false
    @State var wrongAttemptCount : Int = 0
    
    func isCorrectCode(pinCode:String) -> Bool{
        let postalcodeRegex = "^[0-9]{5}?$"
        let pinPredicate = NSPredicate(format: "SELF MATCHES %@", postalcodeRegex)
        var bool = pinPredicate.evaluate(with: pinCode) as Bool
        
        //Убараем нормальный механизм и ставим тупой
        if bool {
            var tCodeArr:[Int] = []
            pinCode.forEach { character in
                tCodeArr.append(character.wholeNumberValue!)
            }
            // 12345
            if tCodeArr[1] == (tCodeArr[0] + 1)
                && tCodeArr[2] == (tCodeArr[1] + 1)
                && tCodeArr[3] == (tCodeArr[2] + 1)
                && tCodeArr[4] == (tCodeArr[3] + 1){
                return false
            }
            //54321
            if tCodeArr[1] == (tCodeArr[0] - 1)
                && tCodeArr[2] == (tCodeArr[1] - 1)
                && tCodeArr[3] == (tCodeArr[2] - 1)
                && tCodeArr[4] == (tCodeArr[3] - 1){
                return false
            }
            //11111
            if tCodeArr[0] == tCodeArr[1] && tCodeArr[1] == tCodeArr[2] && tCodeArr[2] == tCodeArr[3] && tCodeArr[3] == tCodeArr[4]{
                return false
            }
            //константы
            switch tCodeArr {
            case  [8,9,0,1,2], [2,1,0,9,8], [7,5,3,1,4], [9,5,1,3,6], [8,6,2,4,5], [6,2,4,8,5], [2,4,8,6,5], [5,2,4,8,6], [5,8,6,2,4], [3,5,7,9,6], [1,5,9,7,4], [7,5,3,6,9], [9,5,1,4,7], [9,6,3,5,7], [7,4,1,5,9]:
                return false
            default:
                break
            }
            // – AAA –AAAA
            if tCodeArr[0] == tCodeArr[1] && tCodeArr[1] == tCodeArr[2]
                || tCodeArr[1] == tCodeArr[2] && tCodeArr[2] == tCodeArr[3]
                || tCodeArr[2] == tCodeArr[3] && tCodeArr[3] == tCodeArr[4]  {
                return false
            }
            
            if tCodeArr[0] == tCodeArr[1] && tCodeArr[1] == tCodeArr[2] && tCodeArr[2] == tCodeArr[3]
                || tCodeArr[1] == tCodeArr[2] && tCodeArr[2] == tCodeArr[3] && tCodeArr[3] == tCodeArr[4] {
                return false
            }
            // не должен содержать парных комбинаций AB располагающихся последовательно ABABC,CABAB или разделенных цифрой ABCAB
            var arr:[String] = []
            var twoElement:String = ""
            var t_element:Character?
            
            for (inx, val) in pinCode.enumerated() {
                switch inx {
                case 0:
                    twoElement.append(val)
                case 1:
                    t_element = val
                    twoElement.append(val)
                    arr.append(twoElement)
                case 2:
                    twoElement.removeAll()
                    twoElement.append(t_element!)
                    twoElement.append(val)
                    t_element = val
                    arr.append(twoElement)
                case 3:
                    twoElement.removeAll()
                    twoElement.append(t_element!)
                    twoElement.append(val)
                    t_element = val
                    arr.append(twoElement)
                case 4:
                    twoElement.removeAll()
                    twoElement.append(t_element!)
                    twoElement.append(val)
                    t_element = val
                    arr.append(twoElement)
                default:
                    break
                }
            }
            //AA
            arr.forEach { element in
                if element.first == element.last {
                    bool = false
                }
            }
            var counts: [String: Int] = [:]
            arr.forEach { counts[$0, default: 0] += 1 }
            let result = counts.filter({$0.value > 1})
            if result.count > 0 {
                return false
            }
        }
        return bool
    }
    
    
    func add(_ char: String){
        
        if self.wrongAttempt {
            return
        }
        if self.pin.count < 5 && self.api.ui == .pin {
            self.pin.append(char)
        }
        if self.pin.count < 5 && self.api.ui == .pinCreate {
            self.pin.append(char)
        }
        if self.pin.count == 5 && self.api.ui == .pinCreate {
            switch self.attemptsRegistration {
            case false:
                if (isCorrectCode(pinCode: self.pin.joined())){
                    self.pinRepeat = self.pin
                    self.pin.removeAll()
                    self.attemptsRegistration = true
                }else{
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation {
                        self.wrongAttempt.toggle()
                    }
                    DispatchQueue.main.async {
                        
                        Settings.shared.alert(title: "Pin Error", message: "Very simple pin-code", buttonName: "ok")
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        withAnimation {
                            self.wrongAttempt.toggle()
                        }
                        self.pin.removeAll()
                    })
                }
            case true:
                if (self.pin == self.pinRepeat){
                    
                    self.api.authorization.savePasscode(passcode: self.pin.joined())
                }else{
                    self.pin.removeAll()
                    self.pinRepeat.removeAll()
                    self.attemptsRegistration = false
                    
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    DispatchQueue.main.async {
                        Settings.shared.alert(title: "Error",
                                              message: "The pin code does not match the one entered earlier",
                                              buttonName: "Repeat")
                    }
                }
            }
        }
        
        if self.pin.count == 5 && self.api.ui == .pin {
            if !self.api.authorization.verifyPasscode(passcode: self.pin.joined()) {
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                if (self.wrongAttemptCount > 2){
                    return
                }
                if (self.wrongAttemptCount == 2){
                    
                    self.wrongAttemptCount += 1
                    withAnimation {
                        self.wrongAttempt.toggle()
                    }
                    DispatchQueue.main.async {
                        Settings.shared.alert(title: "Error", message: "You need to perform authorization", buttonName: "Okey")
                        Settings.shared.logout()
                    }
                    return
                }
                
                self.wrongAttemptCount += 1
                DispatchQueue.main.async {
                    Settings.shared.alert(title: "Error", message: "The pin code does not match", buttonName: "Repeat")
                }
                
                withAnimation {
                    self.wrongAttempt.toggle()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    withAnimation {
                        self.wrongAttempt.toggle()
                    }
                    self.pin.removeAll()
                })
            }
        }
    }
    
    func remove(){
        if self.wrongAttemptCount > 2{
            return
        }
        if self.pin.count > 0{
            self.pin.removeLast()
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 30){
            
            VStack(spacing: 15){
                if (self.api.ui == .pin){
                    Text("Enter pin code")
                        .foregroundColor(Color.black)
                        .modifier(NCRPTTextMedium(size: 16))
                    
                }
                if (self.api.ui == .pinCreate && self.attemptsRegistration == false){
                    Text("Create pin code")
                        .foregroundColor(Color.black)
                        .modifier(NCRPTTextMedium(size: 16))
                }
                if (self.api.ui == .pinCreate && self.attemptsRegistration == true){
                    Text("Repeat pin code")
                        .foregroundColor(Color.black)
                        .modifier(NCRPTTextMedium(size: 16))
                }
                
                HStack(spacing: 10){
                    ForEach(0...4, id:\.self){ value in
                        Circle()
                            .fill(self.pin.indices.contains(value) ? self.wrongAttempt ? Color.red.opacity(0.85) :  Color.black.opacity(0.55) : Color.black.opacity(0.1))
                            .frame(width: 15, height: 15, alignment: .center)
                    }
                }
            }
            
            //            FIRST ROW
            HStack(spacing: 40){
                
                Button(action: {
                    self.add("1")
                }, label: {
                    Text("1")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }).buttonStyle(PinButtonStyle())
                
                Button(action: {
                    self.add("2")
                }, label: {
                    Text("2")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }).buttonStyle(PinButtonStyle())
                
                Button(action: {
                    self.add("3")
                }, label: {
                    Text("3")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                    
                }).buttonStyle(PinButtonStyle())
            }
            
            //            SECOND ROW
            
            HStack(spacing: 40){
                
                Button(action: {
                    self.add("4")
                }, label: {
                    Text("4")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }).buttonStyle(PinButtonStyle())
                
                Button(action: {
                    self.add("5")
                }, label: {
                    Text("5")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }).buttonStyle(PinButtonStyle())
                
                Button(action: {
                    self.add("6")
                }, label: {
                    Text("6")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }).buttonStyle(PinButtonStyle())
                
            }
            //            THIRD ROW
            HStack(spacing: 40){
                
                Button(action: {
                    self.add("7")
                }, label: {
                    Text("7")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }).buttonStyle(PinButtonStyle())
                
                Button(action: {
                    self.add("8")
                }, label: {
                    Text("8")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }).buttonStyle(PinButtonStyle())
                Button(action: {
                    self.add("9")
                }, label: {
                    Text("9")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }).buttonStyle(PinButtonStyle())
            }
            HStack(spacing: 40){
                Button(action: {
                    let context = LAContext()
                    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please authenticate to proceed.") { (success, error) in
                            if success {
                                DispatchQueue.main.async {
                                    withAnimation{
                                        NCRPTWatchSDK.shared.ui = .loading
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation{
                                        NCRPTWatchSDK.shared.ui = .ready
                                    }
                                    //close screen
                                }
                            } else {
                                guard let error = error else { return }
                                print(error.localizedDescription)
                            }
                        }
                    }
                }, label: {
                    Image(systemName: "faceid")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }).buttonStyle(PinButtonStyle())
                Button(action: {
                    self.add("0")
                }, label: {
                    Text("0")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }).buttonStyle(PinButtonStyle())
                Button(action: {
                    self.remove()
                }, label: {
                    Image(systemName: "xmark.square")
                        .padding(15)
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                    
                }).buttonStyle(PinButtonStyle())
            }
        }
    }
}

struct PinButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .modifier(NCRPTTextMedium(size: 16))
            .frame(width: 64, height: 64, alignment: .center)
            .background(configuration.isPressed ? Color.secondary.opacity(0.15) : Color(UIColor.clear))
            .cornerRadius(32)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
