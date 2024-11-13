//
//  SSOEncryption.swift
//  OneAuthV2
//
//  Created by Abinaya Ravichandran on 25/06/20.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoKit
import CryptoSwift

@available(iOS 11.0, *)
@available(watchOS 4.0, *)
@objcMembers
public class SSOEncryption: NSObject {
    
    let aesIVSize: Int = 12
    
    public func getGCMEncryptedData(for jsonToEncrypt: Dictionary<String, Any>, keyString : String) -> String? {
        
        if #available(iOS 13.0, *), #available(watchOS 6.0, *) {
            let keyData = Data(keyString.utf8)
            let key = SymmetricKey(data: keyData)
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonToEncrypt)
                let sealedBox = try AES.GCM.seal(jsonData, using: key)
                guard var base64String = sealedBox.combined?.base64EncodedString(options: .endLineWithLineFeed) else {
                    return nil
                }
                while base64String.hasSuffix("==") {
                    base64String = String(base64String.dropLast(2))
                }
                // Step 3: URL-encode the base64 string
                let urlEncodedBase64 = base64String.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                return urlEncodedBase64
            } catch let gcmError {
                debugPrint("GCM EncryptedData Error: \(gcmError.localizedDescription)")
                return nil
            }
        } else {
            let encryptedString = getEncryptedStringUsingCryptoSwift(for: jsonToEncrypt, keyData: Data(keyString.utf8))
            return encryptedString
        }
    }
    
    func getEncryptedStringUsingCryptoSwift(for dictionary:Dictionary<String,Any>, keyData:Data) -> String? {
        let iv = AES.randomIV(aesIVSize)
        do {
            let keyUInt = [UInt8](keyData)
            let key = keyUInt
            
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let string = [UInt8](data)
            
            let gcm = GCM(iv: iv, mode: .combined)
            let aes = try AES(key: key, blockMode: gcm, padding: .noPadding)
            
            let encrypted = try aes.encrypt(string)
            
            // Adding IV on encrypted string [First 12 element is IV]
            let encryptedData = Data(bytes: iv + encrypted, count: (iv + encrypted).count)
            var base64EncryptedString = encryptedData.base64EncodedString()
            
            while base64EncryptedString.hasSuffix("==") {
                base64EncryptedString = String(base64EncryptedString.dropLast(2))
            }
            // Step 3: URL-encode the base64 string
            let urlEncodedBase64 = base64EncryptedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return urlEncodedBase64
        } catch let encryptError {
            debugPrint("encryptError", encryptError)
            return nil
        }
    }
}
