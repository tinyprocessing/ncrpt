import CommonCrypto
import Foundation

struct AES {
    // MARK: - Value

    public let key: Data
    public let iv: Data

    // MARK: - Initialzier

    init?(key: Data, iv: Data) {
        self.key = key
        self.iv = iv
    }
}
