//
//  Certification.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 05.11.2022.
//

import Foundation
import SwiftUI
import CommonCrypto
import Security
import openssl

fileprivate typealias X509 = OpaquePointer

class Certification: ObservableObject, Identifiable  {
    public var certificate = Certificate()
    public var identity : SecIdentity? = nil
    
    private func transportPasswordGeneration(_ bits : Int) -> String {
        let chars : String = "abcdefghijklmnopqrstuvwxyz"
        let charsUpper : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let digits : String = "123456789"
        let spetials : String = "!@#$%^&*?"
        
        var password : String = ""
        
        for _ in 1...bits/4 {
            let tmp : String = String(chars.randomElement()!) + String(charsUpper.randomElement()!) + String(digits.randomElement()!) + String(spetials.randomElement()!)
            password += tmp
        }
        return password
    }
    
    func importCertificate(_ certificate : Data, _ password : String) -> Bool {
        var importResult: CFArray? = nil
        let err = SecPKCS12Import(
            certificate as NSData,
            [kSecImportExportPassphrase as String: password] as NSDictionary,
            &importResult
        )
        do {
            guard err == errSecSuccess else {
                throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
            }
            
//            kSecImportItemCertChain
            let identityDictionaries = importResult as! [[String:Any]]
            let readySecIdentity = identityDictionaries[0][kSecImportItemIdentity as String] as! SecIdentity

            var secCert: SecCertificate?
            SecIdentityCopyCertificate(readySecIdentity, &secCert)
            
            if (secCert == nil){
                return false
            }
            
            var keychainQueryDictionary = [String : Any]()
            
            if let tempSecCert = secCert {
                keychainQueryDictionary = [kSecClass as String : kSecClassCertificate, kSecValueRef as String : tempSecCert, kSecAttrLabel as String: "NCRPT Viewer"]
            }
            
            let summary = SecCertificateCopySubjectSummary(secCert!)! as String
            print("Cert summary: \(summary)")
            
            let status = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
            
            guard status == errSecSuccess else {
                print("Error")
                return false
            }
            
            keychainQueryDictionary = [String : Any]()
            
            
            keychainQueryDictionary = [kSecValueRef as String : readySecIdentity,
                                       kSecAttrLabel as String: "NCRPT Viewer"]
            
            
            let statusIdentity = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
            
            guard statusIdentity == errSecSuccess else {
                print("Error")
                return false
            }
            
            
            print("ready import")
            
            return true
            
        } catch {
            print("some error")
            
            return false
        }
    }
    
    func getCertificate() {
        
        let query = [
            kSecClass: kSecClassIdentity,
            kSecReturnAttributes: true,
            kSecReturnRef: true,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitAll
        ] as CFDictionary
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        let array = result as! [NSDictionary]
        
        for i in 0...array.count-1 {
            let identity = array[i]["v_Ref"] as! SecIdentity
            print(identity)
            var certRef: SecCertificate?
            SecIdentityCopyCertificate(identity, &certRef)
            let data = SecCertificateCopyData(certRef!) as NSData
            var firstByte: UnsafePointer? = data.bytes.assumingMemoryBound(to: UInt8.self)
            let certificateX509 = d2i_X509(nil, &firstByte, data.length)
            let subjectX509Name = X509_get_subject_name(certificateX509)
            if (subjectX509Name != nil) {
                let organizationUnitName = getSubjectPartName(from: subjectX509Name, forKey: "2.5.4.11") ?? ""
                print(organizationUnitName)
                print("email = ", getSubjectPartName(from: subjectX509Name, forKey: "1.2.840.113549.1.9.1") as Any)
                print("name = ", getSubjectPartName(from: subjectX509Name, forKey: "2.5.4.4") as Any)
                print("given = ", getSubjectPartName(from: subjectX509Name, forKey: "2.5.4.42") as Any)
                print("common = ", getSubjectPartName(from: subjectX509Name, forKey: "2.5.4.3") as Any)
                print("organizationUnitName = ", getSubjectPartName(from: subjectX509Name, forKey: "2.5.4.11") as Any)
            }
        }
    }
    
    func getSubjectPartName(from x509Name: UnsafeMutablePointer<X509_NAME>?, forKey key: String) -> String? {
        var partList: [String] = []
        let pointer: UnsafePointer<Int8>? = NSString(string: key).utf8String
        let nid = OBJ_txt2nid(pointer)
        var index = X509_NAME_get_index_by_NID(x509Name, nid, -1)
        var x509nameEntry = X509_NAME_get_entry(x509Name, index)
        
        while ((x509nameEntry) != nil) {
            let asn1Str = X509_NAME_ENTRY_get_data(x509nameEntry)
            if (asn1Str != nil) {
                let charName = ASN1_STRING_data(asn1Str)
                
                if let asn1Str = asn1Str {
                    let charName = UnsafePointer(ASN1_STRING_data(asn1Str))
                    partList.append(String(cString: charName!))
                    index = X509_NAME_get_index_by_NID(x509Name, nid, index)
                    x509nameEntry = X509_NAME_get_entry(x509Name, index)
                }
            }
        }
        return partList.joined(separator: ".")
    }
    
    func loadIdentity() -> SecIdentity? {
        
        let query = [
            kSecClass: kSecClassIdentity,
            kSecReturnAttributes: true,
            kSecReturnRef: true,
            kSecMatchLimit: kSecMatchLimitAll
        ] as CFDictionary
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        
        print("Operation finished with status: \(status)")
        if result == nil {
            print("not found")
            return nil
        }
        
        let array = result as! [NSDictionary]
       
        return (array[0]["v_Ref"] as! SecIdentity)
       
    }
}

public class Certificate: NSObject {
    var version = 0
    var validFrom: Date?
    var validTo: Date?
    var issuer: String?
    var serialNumber: String?
    var thumbPrint: String?
    var email: String?
    var subject: String?
    var printableSubject: String?
    var certTrustStatus: CertTrust?
    private(set) var name: String?
    private(set) var privateKeyUsageEnabled = false
    private(set) var certificateIsValid = false
    var subjectExtensions: [AnyHashable : Any]?
}


enum CertTrust : Int {
    case noError = 0
    case timeInvalid = 1
    case revoked = 2
    case signatureInvalid = 3
    case usageInvalid = 4
    case untrustedRoot = 5
    case unknownRevokationStatus = 6
    case cyclyc = 7
    case incompleteChain = 8
    case ctlTimeInvalid = 9
    case ctlSignatureInvalid = 10
    case ctlUsageInvalid = 11
    case unknownError = 12
}

enum crtKeyName: String {
    case email = "1.2.840.113549.1.9.1"
    case name = "2.5.4.4"
    case given = "2.5.4.42"
    case common = "2.5.4.3"
    case orgUnitName = "2.5.4.11"
}
