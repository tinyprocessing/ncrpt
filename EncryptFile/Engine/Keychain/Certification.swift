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
            
            let summary = SecCertificateCopySubjectSummary(secCert!)! as String
            print("Cert summary: \(summary)")
            
#if IOSSYSTEM
            
            var keychainQueryDictionary = [String : Any]()
            
            if let tempSecCert = secCert {
                keychainQueryDictionary = [kSecClass as String : kSecClassCertificate, kSecValueRef as String : tempSecCert, kSecAttrLabel as String: "NCRPT Viewer"]
            }
            
            
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
#endif
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
        
        if status == -25300 {
            return
        }
        
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
            let issureX509Name = X509_get_issuer_name(certificateX509)
            
            if (subjectX509Name != nil) {
                self.certificate.certificationOIDs = []
                let organizationUnitName = getSubjectPartName(from: subjectX509Name, forKey: "2.5.4.11") ?? ""
                
                if issureX509Name != nil {
                    let nid = OBJ_txt2nid("CN");
                    let index = X509_NAME_get_index_by_NID(issureX509Name, nid, -1);
                    if (index != -1) {
                        let issuerNameCommonName = X509_NAME_get_entry(issureX509Name, index);
                        if (issuerNameCommonName != nil) {
                            let issuerCNASN1 = X509_NAME_ENTRY_get_data(issuerNameCommonName);
                            if (issuerCNASN1 != nil) {
                                let issuerCName = ASN1_STRING_data(issuerCNASN1);
                                if let bytes = issuerCName {
                                    let issure = String(cString: bytes)
                                    self.certificate.issuer = issure
                                }
                            }
                        }
                    }
                }
                
                let serialNumber = X509_get_serialNumber(certificateX509)
                
                
                self.certificate.email = getSubjectPartName(from: subjectX509Name, forKey: "1.2.840.113549.1.9.1")
                self.certificate.name = getSubjectPartName(from: subjectX509Name, forKey: "2.5.4.4")
                
                self.certificate.certificationOIDs.append(CertificateOID(name: "Name",
                                                                         value: self.certificate.issuer ?? ""))
                
                self.certificate.certificationOIDs.append(CertificateOID(name: "Email",
                                                                         value: getSubjectPartName(from: subjectX509Name,
                                                                                                   forKey: "1.2.840.113549.1.9.1") ?? "-"))
                self.certificate.certificationOIDs.append(CertificateOID(name: "serialNumber",
                                                                         value: String(describing: serialNumber)))
                
                
                let structOID = certificationOIDs()
                let mirror = Mirror(reflecting: structOID)
                
                autoreleasepool {
                    for child in mirror.children  {
                        let value = getSubjectPartName(from: subjectX509Name, forKey: child.value as! String) ?? ""
                        if value.count > 0 {
                            var oid = CertificateOID()
                            oid.name = (child.label ?? "-").replacingOccurrences(of: "kSecOID", with: "")
                            oid.value = String(describing: value)
                            self.certificate.certificationOIDs.append(oid)
                        }
                    }
                }
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
    
    func loadIdentity(_ inDepth: Int = 0) -> SecIdentity? {
        
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
        print("array count idenety: ", array.count)
        var resultSI : SecIdentity? = nil
        array.forEach { certificate in
            if let issr = String(data: certificate["issr"] as! Data, encoding: .ascii) {
                if issr.contains("NCRPTCA Root"){
                    resultSI = (certificate["v_Ref"] as! SecIdentity)
                }
            }
        }
        return resultSI
    }
    
    func certificateThumbprintFromContext(_ certificateData: Data?) -> String? {
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        certificateData?.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(certificateData!.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
        
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
    var name: String?
    private(set) var privateKeyUsageEnabled = false
    private(set) var certificateIsValid = false
    var subjectExtensions: [AnyHashable : Any]?
    var certificationOIDs : [CertificateOID] = []
}

struct CertificateOID: Identifiable, Hashable {
    var id: Int = 0
    var name : String = ""
    var value : String = ""
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


struct certificationOIDs {
    var kSecOIDADC_CERT_POLICY = "1.2.840.113635.100.5.3"
    var kSecOIDAPPLE_CERT_POLICY = "1.2.840.113635.100.5.1"
    var kSecOIDAPPLE_EKU_CODE_SIGNING = "1.2.840.113635.100.4.1"
    var kSecOIDAPPLE_EKU_CODE_SIGNING_DEV = "1.2.840.113635.100.4.1.1"
    var kSecOIDAPPLE_EKU_ICHAT_ENCRYPTION = "1.2.840.113635.100.4.3"
    var kSecOIDAPPLE_EKU_ICHAT_SIGNING = "1.2.840.113635.100.4.2"
    var kSecOIDAPPLE_EKU_RESOURCE_SIGNING = "1.2.840.113635.100.4.1.4"
    var kSecOIDAPPLE_EKU_SYSTEM_IDENTITY = "1.2.840.113635.100.4.4"
    var kSecOIDAPPLE_EXTENSION = "1.2.840.113635.100.6"
    var kSecOIDAPPLE_EXTENSION_ADC_APPLE_SIGNING = "1.2.840.113635.100.6.1.2.0.0"
    var kSecOIDAPPLE_EXTENSION_ADC_DEV_SIGNING = "1.2.840.113635.100.6.1.2.0"
    var kSecOIDAPPLE_EXTENSION_APPLE_SIGNING = "1.2.840.113635.100.6.1.1"
    var kSecOIDAPPLE_EXTENSION_CODE_SIGNING = "1.2.840.113635.100.6.1"
    var kSecOIDAPPLE_EXTENSION_INTERMEDIATE_MARKER = "1.2.840.113635.100.6.2"
    var kSecOIDAPPLE_EXTENSION_WWDR_INTERMEDIATE = "1.2.840.113635.100.6.2.1"
    var kSecOIDAPPLE_EXTENSION_ITMS_INTERMEDIATE = "1.2.840.113635.100.6.2.2"
    var kSecOIDAPPLE_EXTENSION_AAI_INTERMEDIATE = "1.2.840.113635.100.6.2.3"
    var kSecOIDAPPLE_EXTENSION_APPLEID_INTERMEDIATE = "1.2.840.113635.100.6.2.7"
    var kSecOIDAuthorityInfoAccess = "1.3.6.1.5.5.7.1.1"
    var kSecOIDAuthorityKeyIdentifier = "2.5.29.35"
    var kSecOIDBasicConstraints = "2.5.29.19"
    var kSecOIDBiometricInfo = "1.3.6.1.5.5.7.1.2"
    var kSecOIDCSSMKeyStruct = "2.16.840.1.113741.2.1.1.1.20"
    var kSecOIDCertIssuer = "2.5.29.29"
    var kSecOIDCertificatePolicies = "2.5.29.32"
    var kSecOIDClientAuth = "1.3.6.1.5.5.7.3.2"
    var kSecOIDCollectiveStateProvinceName = "2.5.4.8.1"
    var kSecOIDCollectiveStreetAddress = "2.5.4.9.1"
    var kSecOIDCommonName = "2.5.4.3"
    var kSecOIDCountryName = "2.5.4.6"
    var kSecOIDCrlDistributionPoints = "2.5.29.31"
    var kSecOIDCrlNumber = "2.5.29.20"
    var kSecOIDCrlReason = "2.5.29.21"
    var kSecOIDDOTMAC_CERT_EMAIL_ENCRYPT = "1.2.840.113635.100.3.2.3"
    var kSecOIDDOTMAC_CERT_EMAIL_SIGN = "1.2.840.113635.100.3.2.2"
    var kSecOIDDOTMAC_CERT_EXTENSION = "1.2.840.113635.100.3.2"
    var kSecOIDDOTMAC_CERT_IDENTITY = "1.2.840.113635.100.3.2.1"
    var kSecOIDDOTMAC_CERT_POLICY = "1.2.840.113635.100.5.2"
    var kSecOIDDeltaCrlIndicator = "2.5.29.27"
    var kSecOIDDescription = "2.5.4.13"
    var kSecOIDEKU_IPSec = "1.3.6.1.5.5.8.2.2"
    var kSecOIDEmailAddress = "1.2.840.113549.1.9.1"
    var kSecOIDEmailProtection = "1.3.6.1.5.5.7.3.4"
    var kSecOIDExtendedKeyUsage = "2.5.29.37"
    var kSecOIDExtendedKeyUsageAny = "2.5.29.37.0"
    var kSecOIDExtendedUseCodeSigning = "1.3.6.1.5.5.7.3.3"
    var kSecOIDGivenName = "2.5.4.42"
    var kSecOIDHoldInstructionCode = "2.5.29.23"
    var kSecOIDInvalidityDate = "2.5.29.24"
    var kSecOIDIssuerAltName = "2.5.29.18"
    var kSecOIDIssuingDistributionPoint = "2.5.29.28"
    var kSecOIDIssuingDistributionPoints = "2.5.29.28"
    var kSecOIDKERBv5_PKINIT_KP_CLIENT_AUTH = "1.3.6.1.5.2.3.4"
    var kSecOIDKERBv5_PKINIT_KP_KDC = "1.3.6.1.5.2.3.5"
    var kSecOIDKeyUsage = "2.5.29.15"
    var kSecOIDLocalityName = "2.5.4.7"
    var kSecOIDMS_NTPrincipalName = "1.3.6.1.4.1.311.20.2.3"
    var kSecOIDMicrosoftSGC = "1.3.6.1.4.1.311.10.3.3"
    var kSecOIDNameConstraints = "2.5.29.30"
    var kSecOIDNetscapeCertSequence = "2.16.840.1.113730.2.5"
    var kSecOIDNetscapeCertType = "2.16.840.1.113730.1.1"
    var kSecOIDNetscapeSGC = "2.16.840.1.113730.4.1"
    var kSecOIDOCSPSigning = "1.3.6.1.5.5.7.3.9"
    var kSecOIDOrganizationName = "2.5.4.10"
    var kSecOIDOrganizationalUnitName = "2.5.4.11"
    var kSecOIDPolicyConstraints = "2.5.29.36"
    var kSecOIDPolicyMappings = "2.5.29.33"
    var kSecOIDPrivateKeyUsagePeriod = "2.5.29.16"
    var kSecOIDQC_Statements = "1.3.6.1.5.5.7.1.3"
    var kSecOIDSerialNumber = "2.5.4.5"
    var kSecOIDServerAuth = "1.3.6.1.5.5.7.3.1"
    var kSecOIDStateProvinceName = "2.5.4.8"
    var kSecOIDStreetAddress = "2.5.4.9"
    var kSecOIDSubjectAltName = "2.5.29.17"
    var kSecOIDSubjectDirectoryAttributes = "2.5.29.9"
    var kSecOIDSubjectEmailAddress = "2.16.840.1.113741.2.1.1.1.50.3"
    var kSecOIDSubjectInfoAccess = "1.3.6.1.5.5.7.1.11"
    var kSecOIDSubjectKeyIdentifier = "2.5.29.14"
    var kSecOIDSubjectPicture = "2.16.840.1.113741.2.1.1.1.50.2"
    var kSecOIDSubjectSignatureBitmap = "2.16.840.1.113741.2.1.1.1.50.1"
    var kSecOIDSurname = "2.5.4.4"
    var kSecOIDTimeStamping = "1.3.6.1.5.5.7.3.8"
    var kSecOIDTitle = "2.5.4.12"
    var kSecOIDUseExemptions = "2.16.840.1.113741.2.1.1.1.50.4"
    var kSecOIDX509V1CertificateIssuerUniqueId = "2.16.840.1.113741.2.1.1.1.11"
    var kSecOIDX509V1CertificateSubjectUniqueId = "2.16.840.1.113741.2.1.1.1.12"
    var kSecOIDX509V1IssuerName = "2.16.840.1.113741.2.1.1.1.5"
    var kSecOIDX509V1IssuerNameCStruct = "2.16.840.1.113741.2.1.1.1.5.1"
    var kSecOIDX509V1IssuerNameLDAP = "2.16.840.1.113741.2.1.1.1.5.2"
    var kSecOIDX509V1IssuerNameStd = "2.16.840.1.113741.2.1.1.1.23"
    var kSecOIDX509V1SerialNumber = "2.16.840.1.113741.2.1.1.1.3"
    var kSecOIDX509V1Signature = "2.16.840.1.113741.2.1.3.2.2"
    var kSecOIDX509V1SignatureAlgorithm = "2.16.840.1.113741.2.1.3.2.1"
    var kSecOIDX509V1SignatureAlgorithmParameters = "2.16.840.1.113741.2.1.3.2.3"
    var kSecOIDX509V1SignatureAlgorithmTBS = "2.16.840.1.113741.2.1.3.2.10"
    var kSecOIDX509V1SignatureCStruct = "2.16.840.1.113741.2.1.3.2.0.1"
    var kSecOIDX509V1SignatureStruct = "2.16.840.1.113741.2.1.3.2.0"
    var kSecOIDX509V1SubjectName = "2.16.840.1.113741.2.1.1.1.8"
    var kSecOIDX509V1SubjectNameCStruct = "2.16.840.1.113741.2.1.1.1.8.1"
    var kSecOIDX509V1SubjectNameLDAP = "2.16.840.1.113741.2.1.1.1.8.2"
    var kSecOIDX509V1SubjectNameStd = "2.16.840.1.113741.2.1.1.1.22"
    var kSecOIDX509V1SubjectPublicKey = "2.16.840.1.113741.2.1.1.1.10"
    var kSecOIDX509V1SubjectPublicKeyAlgorithm = "2.16.840.1.113741.2.1.1.1.9"
    var kSecOIDX509V1SubjectPublicKeyAlgorithmParameters = "2.16.840.1.113741.2.1.1.1.18"
    var kSecOIDX509V1SubjectPublicKeyCStruct = "2.16.840.1.113741.2.1.1.1.20.1"
    var kSecOIDX509V1ValidityNotAfter = "2.16.840.1.113741.2.1.1.1.7"
    var kSecOIDX509V1ValidityNotBefore = "2.16.840.1.113741.2.1.1.1.6"
    var kSecOIDX509V1Version = "2.16.840.1.113741.2.1.1.1.2"
    var kSecOIDX509V3Certificate = "2.16.840.1.113741.2.1.1.1.1"
    var kSecOIDX509V3CertificateCStruct = "2.16.840.1.113741.2.1.1.1.1.1"
    var kSecOIDX509V3CertificateExtensionCStruct = "2.16.840.1.113741.2.1.1.1.13.1"
    var kSecOIDX509V3CertificateExtensionCritical = "2.16.840.1.113741.2.1.1.1.16"
    var kSecOIDX509V3CertificateExtensionId = "2.16.840.1.113741.2.1.1.1.15"
    var kSecOIDX509V3CertificateExtensionStruct = "2.16.840.1.113741.2.1.1.1.13"
    var kSecOIDX509V3CertificateExtensionType = "2.16.840.1.113741.2.1.1.1.19"
    var kSecOIDX509V3CertificateExtensionValue = "2.16.840.1.113741.2.1.1.1.17"
    var kSecOIDX509V3CertificateExtensionsCStruct = "2.16.840.1.113741.2.1.1.1.21.1"
    var kSecOIDX509V3CertificateExtensionsStruct = "2.16.840.1.113741.2.1.1.1.21"
    var kSecOIDX509V3CertificateNumberOfExtensions = "2.16.840.1.113741.2.1.1.1.14"
    var kSecOIDX509V3SignedCertificate = "2.16.840.1.113741.2.1.1.1.0"
    var kSecOIDX509V3SignedCertificateCStruct = "2.16.840.1.113741.2.1.1.1.0.1"
    var kSecOIDSRVName = "1.3.6.1.5.5.7.8.7"
}
