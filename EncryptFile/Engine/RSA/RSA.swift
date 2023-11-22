//
//  Rsa.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import Foundation
import SwiftyRSA

class RSA: ObservableObject, Identifiable {

    func generatePairKeys() -> (String?, String?) {
        do {
            let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 4096)
            let privateKey = keyPair.privateKey
            let publicKey = keyPair.publicKey

            let testMethod = try publicKey.data()
            let pem = PEMKeyFromDERKey(
                data: exportRSAPublicKeyToDER(
                    rawPublicKeyBytes: testMethod as! NSData,
                    keyType: kSecAttrKeyTypeRSA as String,
                    keySize: 4096
                )
            )

            return (try privateKey.pemString(), pem)
        }
        catch {
            print(error)
        }
        return (nil, nil)
    }

    func start() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: UserDefaults.Keys.RSASetup.rawValue)
        log.debug(module: "RSA", type: #function, object: "Loading RSA module")
        let keychainStatus: Bool = defaults.bool(forKey: UserDefaults.Keys.RSASetup.rawValue)
        if keychainStatus == false {
            log.debug(module: "RSA", type: #function, object: "User is first time")
            defaults.set(true, forKey: UserDefaults.Keys.RSASetup.rawValue)
            let keys = self.generatePairKeys()
            if keys.1 != nil && keys.0 != nil {
                let keychain = Keychain()
                keychain.helper.removePassword(
                    service: "keychainPublicKey",
                    account: "NCRPT"
                )
                keychain.helper.removePassword(
                    service: "keychainPrivateKey",
                    account: "NCRPT"
                )
                keychain.helper.savePassword(
                    service: "keychainPrivateKey",
                    account: "NCRPT",
                    data: keys.0 ?? ""
                )
                keychain.helper.savePassword(
                    service: "keychainPublicKey",
                    account: "NCRPT",
                    data: keys.1 ?? ""
                )
                log.debug(
                    module: "RSA",
                    type: #function,
                    object: "Keys saved to keychain"
                )
            }
        }
    }

    func getPublicKey() -> String? {
        let keychain = Keychain()
        return keychain.helper.loadPassword(service: "keychainPublicKey", account: "NCRPT")
    }
}

// RSA OID header
private let kCryptoExportImportManagerRSAOIDHeader: [UInt8] = [
    0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00,
]
private let kCryptoExportImportManagerRSAOIDHeaderLength = 15

// ASN.1 encoding parameters.
private let kCryptoExportImportManagerASNHeaderSequenceMark: UInt8 = 48  // 0x30
private let kCryptoExportImportManagerASNHeaderIntegerMark: UInt8 = 02  // 0x32
private let kCryptoExportImportManagerASNHeaderBitstringMark: UInt8 = 03  //0x03
private let kCryptoExportImportManagerASNHeaderNullMark: UInt8 = 05  //0x05
private let kCryptoExportImportManagerASNHeaderRSAEncryptionObjectMark: UInt8 = 06  //0x06
private let kCryptoExportImportManagerExtendedLengthMark: UInt8 = 128  // 0x80
private let kCryptoExportImportManagerASNHeaderLengthForRSA = 15

// PEM encoding constants
private let kCryptoExportImportManagerPublicKeyInitialTag = "-----BEGIN PUBLIC KEY-----\n"
private let kCryptoExportImportManagerPublicKeyFinalTag = "-----END PUBLIC KEY-----"
private let kCryptoExportImportManagerPublicNumberOfCharactersInALine = 64

func PEMKeyFromDERKey(data: NSData) -> String {
    // base64 encode the result
    let base64EncodedString = data.base64EncodedString()

    // split in lines of 64 characters.
    var currentLine = ""
    var resultString = kCryptoExportImportManagerPublicKeyInitialTag
    var charCount = 0
    for character in base64EncodedString {
        charCount += 1
        currentLine.append(character)
        if charCount == kCryptoExportImportManagerPublicNumberOfCharactersInALine {
            resultString += currentLine + "\n"
            charCount = 0
            currentLine = ""
        }
    }
    // final line (if any)
    if currentLine.count > 0 { resultString += currentLine + "\n" }
    // final tag
    resultString += kCryptoExportImportManagerPublicKeyFinalTag
    return resultString
}

/// Generates an ASN.1 length sequence for the given length. Modifies the buffer parameter by
/// writing the ASN.1 sequence. The memory of buffer must be initialized (i.e: from an NSData).
/// Returns the number of bytes used to write the sequence.
func encodeASN1LengthParameter(length: Int, buffer: UnsafeMutablePointer<UInt8>) -> Int {
    if length < Int(kCryptoExportImportManagerExtendedLengthMark) {
        buffer[0] = UInt8(length)
        return 1  // just one byte was used, no need for length starting mark (0x80).
    }
    else {
        let extraBytes = bytesNeededForRepresentingInteger(number: length)
        var currentLengthValue = length

        buffer[0] = kCryptoExportImportManagerExtendedLengthMark + UInt8(extraBytes)
        for i in 0...extraBytes - 1 {
            //            for (var i = 0; i < extraBytes; i++) {
            buffer[extraBytes - i] = UInt8(currentLengthValue & 0xff)
            currentLengthValue = currentLengthValue >> 8
            //        }
        }
        return extraBytes + 1  // 1 byte for the starting mark (0x80 + bytes used) + bytes used to encode length.
    }
}

/// Returns the number of bytes needed to represent an integer.
func bytesNeededForRepresentingInteger(number: Int) -> Int {
    if number <= 0 { return 0 }
    var i = 1
    while i < 8 && number >= (1 << (i * 8)) { i += 1 }
    return i
}

/// This function prepares a RSA public key generated with Apple SecKeyGeneratePair to be exported
/// and used outisde iOS, be it openSSL, PHP, Perl, whatever. By default Apple exports RSA public
/// keys in a very raw format. If we want to use it on OpenSSL, PHP or almost anywhere outside iOS, we
/// need to remove add the full PKCS#1 ASN.1 wrapping. Returns a DER representation of the key.
func exportRSAPublicKeyToDER(rawPublicKeyBytes: NSData, keyType: String, keySize: Int) -> NSData {
    // first we create the space for the ASN.1 header and decide about its length
    let headerData = NSMutableData(length: kCryptoExportImportManagerASNHeaderLengthForRSA)!
    let bitstringEncodingLength = bytesNeededForRepresentingInteger(number: rawPublicKeyBytes.length)

    // start building the ASN.1 header
    let headerBuffer = UnsafeMutablePointer<UInt8>(OpaquePointer(headerData.mutableBytes))
    headerBuffer[0] = kCryptoExportImportManagerASNHeaderSequenceMark  // sequence start

    // total size (OID + encoding + key size) + 2 (marks)
    let totalSize =
        kCryptoExportImportManagerRSAOIDHeaderLength + bitstringEncodingLength
        + rawPublicKeyBytes.length + 3
    let totalSizebitstringEncodingLength = encodeASN1LengthParameter(
        length: totalSize,
        buffer: &(headerBuffer[1])
    )

    // bitstring header
    let bitstringData = NSMutableData(length: kCryptoExportImportManagerASNHeaderLengthForRSA)!
    let bitstringBuffer = UnsafeMutablePointer<UInt8>(OpaquePointer(bitstringData.mutableBytes))
    bitstringBuffer[0] = kCryptoExportImportManagerASNHeaderBitstringMark  // key length mark
    let keyLengthBytesEncoded = encodeASN1LengthParameter(
        length: rawPublicKeyBytes.length + 1,
        buffer: &(bitstringBuffer[1])
    )
    bitstringBuffer[keyLengthBytesEncoded + 1] = 0x00

    // build DER key.
    let derKey = NSMutableData(capacity: totalSize + totalSizebitstringEncodingLength)!
    derKey.append(headerBuffer, length: totalSizebitstringEncodingLength + 1)  // add sequence and total size
    derKey.append(
        kCryptoExportImportManagerRSAOIDHeader,
        length: kCryptoExportImportManagerRSAOIDHeaderLength
    )  // Add OID header
    derKey.append(bitstringBuffer, length: keyLengthBytesEncoded + 2)  // 0x03 + key bitstring length + 0x00
    derKey.append(rawPublicKeyBytes as Data)  // public key raw data.

    return derKey
}
