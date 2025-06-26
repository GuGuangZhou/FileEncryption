import Foundation
import CommonCrypto

extension Data {
    /// 从十六进制字符串创建Data
    static func dataFromHexString(_ string: String) -> Data {
        let lowercasedString = string.lowercased()
        var data = Data(capacity: lowercasedString.count / 2)
        var i = 0
        let length = lowercasedString.count
        let scanner = Scanner(string: lowercasedString)
        while i < length - 1 {
            let startIndex = lowercasedString.index(lowercasedString.startIndex, offsetBy: i)
            let endIndex = lowercasedString.index(startIndex, offsetBy: 2)
            let substring = String(lowercasedString[startIndex..<endIndex])
            if let byte = UInt8(substring, radix: 16) {
                data.append(byte)
            }
            i += 2
        }
        return data
    }

    /// 加密数据
    func encryptedData(withHexKey hexKey: String, hexIV: String) -> Data? {
        guard let keyData = Data.dataFromHexString(hexKey), keyData.count == kCCKeySizeAES256, 
              let ivData = Data.dataFromHexString(hexIV), ivData.count == kCCKeySizeAES128 else {
            return nil
        }
        let dataLength = count
        let bufferSize = dataLength + kCCBlockSizeAES128
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var numBytesEncrypted: size_t = 0
        let cryptStatus = keyData.withUnsafeBytes { keyPtr in
            ivData.withUnsafeBytes { ivPtr in
                self.withUnsafeBytes { dataPtr in
                    CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                            keyPtr.baseAddress, kCCKeySizeAES256,
                            ivPtr.baseAddress,
                            dataPtr.baseAddress, dataLength,
                            &buffer, bufferSize,
                            &numBytesEncrypted)
                }
            }
        }
        if cryptStatus == kCCSuccess {
            return Data(buffer[0..<numBytesEncrypted])
        }
        return nil
    }

    /// 解密数据
    func originalData(withHexKey hexKey: String, hexIV: String) -> Data? {
        guard let keyData = Data.dataFromHexString(hexKey), keyData.count == kCCKeySizeAES256, 
              let ivData = Data.dataFromHexString(hexIV), ivData.count == kCCKeySizeAES128 else {
            return nil
        }
        let dataLength = count
        let bufferSize = dataLength + kCCBlockSizeAES128
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var numBytesDecrypted: size_t = 0
        let cryptStatus = keyData.withUnsafeBytes { keyPtr in
            ivData.withUnsafeBytes { ivPtr in
                self.withUnsafeBytes { dataPtr in
                    CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                            keyPtr.baseAddress, kCCKeySizeAES256,
                            ivPtr.baseAddress,
                            dataPtr.baseAddress, dataLength,
                            &buffer, bufferSize,
                            &numBytesDecrypted)
                }
            }
        }
        if cryptStatus == kCCSuccess {
            return Data(buffer[0..<numBytesDecrypted])
        }
        return nil
    }
}