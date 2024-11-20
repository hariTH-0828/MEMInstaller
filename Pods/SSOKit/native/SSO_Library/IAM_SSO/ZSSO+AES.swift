//
//  ZSSO+AES.swift
//
//
//  Created by ganesh-15171 on 10/01/24.
//

import Foundation
import CommonCrypto



@objc public extension NSString {
    
    func aesEncrypt(key: String, iv: String) -> String? {
        let string = self as String
        guard
            let data = string.data(using: .utf8) as? NSData,
            let keyData = key.data(using: .utf8),
            let ivData  = iv.data(using: .utf8),
            let encrypt = data.encryptAES(key: keyData, iv: ivData)
        else {
            return nil
        }
        return encrypt.base64EncodedString()
    }
    
    func aesDecrypt(key: String, iv: String) -> String? {
        let string = self as String
        guard
            let base64Data = NSData(base64Encoded: string),
            let keyData = key.data(using: .utf8),
            let ivData  = iv.data(using: .utf8),
            let decrypt = base64Data.decryptAES(key: keyData, iv: ivData)
        else {
            return nil
        }
        return decrypt.base64EncodedString()
    }
    
    func aesCBCEncrypt(key: String) -> String? {
        
        var iv: String
        
        if key.count >= 0 {
            let startIndex = key.startIndex
            let endIndex = key.index(startIndex, offsetBy: 16)
            
            iv = "\(key[startIndex..<endIndex])"
        } else {
            iv = key
        }
        
        
        let string = self as String
        
        guard
            let data = string.data(using: .utf8) as? NSData,
            let ivData = iv.data(using: .utf8),
            let keyData = key.data(using: .utf8) else {
            return nil
        }
        
        return data.encryptAES(key: keyData, iv: ivData, options: kCCOptionPKCS7Padding)?.base64EncodedString()
    }
}


@objc public extension NSData {
    
    func aesCBCEncrypt(key: String) -> String? {
        
        var iv: String
        
        if key.count >= 0 {
            let startIndex = key.startIndex
            let endIndex = key.index(startIndex, offsetBy: 16)
            
            iv = "\(key[startIndex..<endIndex])"
        } else {
            iv = key
        }
        
        
        
        guard
            let ivData = iv.data(using: .utf8),
            let keyData = key.data(using: .utf8) else {
            return nil
        }
        
        return self.encryptAES(key: keyData, iv: ivData, options: kCCOptionPKCS7Padding)?.base64EncodedString()
    }
    
    func aesEncrypt(key: String, ivData: Data?) -> String? {
        guard let keyData = key.data(using: .utf8),
              let encrypt = self.encryptAES(key: keyData, iv: ivData ?? Data())
        else {
            return nil
        }
        return encrypt.base64EncodedString()
    }
    
    /// Encrypts for you with all the good options turned on: CBC, an IV, PKCS7
    /// padding (so your input data doesn't have to be any particular length).
    /// Key can be 128, 192, or 256 bits.
    /// Generates a fresh IV for you each time, and prefixes it to the
    /// returned ciphertext.
    func encryptAES(key: Data, iv: Data, options: Int = kCCOptionECBMode|kCCOptionPKCS7Padding) -> Data? {
        
        // No option is needed for CBC; it is on by default.
        return aesCrypt(operation: kCCEncrypt,
                        algorithm: kCCAlgorithmAES128, // 128
                        options: options,
                        key: key,
                        initializationVector: iv,
                        dataIn: self as Data)
    }

    /// Decrypts self, where self is the IV then the ciphertext.
    /// Key can be 128/192/256 bits.
    func decryptAES(key: Data, iv: Data, options: Int = kCCOptionPKCS7Padding) -> Data? {
        
        guard count > kCCBlockSizeAES128 else {
            return nil
        }
        return aesCrypt(operation: kCCDecrypt,
                        algorithm: kCCAlgorithmAES128, // 128
                        options: options,
                        key: key,
                        initializationVector: iv,
                        dataIn: self as Data)
    }

    
    private func aesCrypt(operation: Int,
                          algorithm: Int,
                          options: Int,
                          key: Data,
                          initializationVector: Data,
                          dataIn: Data) -> Data? {
        return initializationVector.withUnsafeBytes { ivUnsafeRawBufferPointer in
            return key.withUnsafeBytes { keyUnsafeRawBufferPointer in
                return dataIn.withUnsafeBytes { dataInUnsafeRawBufferPointer in
                    // Give the data out some breathing room for PKCS7's padding.
                    let dataOutSize: Int = dataIn.count + kCCBlockSizeAES128 * 2
                    let dataOut = UnsafeMutableRawPointer.allocate(byteCount: dataOutSize, alignment: 1)
                    defer { dataOut.deallocate() }
                    var dataOutMoved: Int = 0
                    let status = CCCrypt(CCOperation(operation),
                                         CCAlgorithm(algorithm),
                                         CCOptions(options),
                                         keyUnsafeRawBufferPointer.baseAddress, key.count,
                                         ivUnsafeRawBufferPointer.baseAddress,
                                         dataInUnsafeRawBufferPointer.baseAddress, dataIn.count,
                                         dataOut, dataOutSize,
                                         &dataOutMoved)
                    guard status == kCCSuccess else { return nil }
                    return Data(bytes: dataOut, count: dataOutMoved)
                }
            }
        }
    }
     
    /*
    private func aesCrypt(
        operation: Int,
        algorithm: Int,
        options: Int,
        key: Data,
        initializationVector: Data,
        dataIn: Data
    ) -> Data? {
        
        var dataOut = Data(count: dataIn.count + kCCBlockSizeAES128 * 2)
        var copiedDataOut = dataOut
        
        let status = copiedDataOut.withUnsafeMutableBytes { dataOutUnsafeMutableRawBufferPointer in
            
            return initializationVector.withUnsafeBytes { ivUnsafeRawBufferPointer in
                
                return key.withUnsafeBytes
                { keyUnsafeRawBufferPointer in
                    
                    return dataIn.withUnsafeBytes { dataInUnsafeRawBufferPointer in
                        
                        return CCCrypt(CCOperation(operation),
                                       CCAlgorithm(algorithm),
                                       CCOptions(options),
                                       keyUnsafeRawBufferPointer.baseAddress, key.count,
                                       ivUnsafeRawBufferPointer.baseAddress,
                                       dataInUnsafeRawBufferPointer.baseAddress, dataIn.count,
                                       dataOutUnsafeMutableRawBufferPointer.baseAddress, dataOut.count,
                                       nil)
                    }
                }
            }
        }
        copiedDataOut.count = dataOut.count
        return status == kCCSuccess ? copiedDataOut : nil
    }
    */
    
    /*
     private func aes128Operation(operation: Int, algorithm: Int, options: Int, key: String, iv: Data?) -> Data? {
         var keyPtr = [CChar](repeating: 0, count: kCCKeySizeAES128 + 1)
         key.getCString(&keyPtr, maxLength: keyPtr.count, encoding: String.Encoding.utf8) // Converts the key to C string.
         
         let dataLength = self.count
         let bufferSize = dataLength + kCCBlockSizeAES128
         var buffer = [UInt8](repeating: 0, count: bufferSize)
         
         var numBytesEncrypted = 0
         
         var result: Data?
         
         _ = iv?.withUnsafeBytes { ivBytes in
             _ = self.withUnsafeBytes { dataBytes in
                 let cryptStatus = CCCrypt(
                     CCOperation(operation),
                     CCAlgorithm(algorithm),
                     CCOptions(options),
                     keyPtr,
                     kCCBlockSizeAES128,
                     ivBytes.baseAddress,
                     dataBytes.baseAddress,
                     dataLength,
                     &buffer,
                     bufferSize,
                     &numBytesEncrypted
                 )
                 
                 if cryptStatus == kCCSuccess {
                     result = Data(bytes: buffer, count: numBytesEncrypted)
                 }
             }
         }
         return result
     }
     */
}
