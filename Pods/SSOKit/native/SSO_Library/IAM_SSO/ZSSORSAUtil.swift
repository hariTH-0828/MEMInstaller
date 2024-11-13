//
//  ZSSORSAUtil.swift
//  IAM_SSO
//
//  Created by Ganesh Murugan N on 15/04/24.
//  Copyright © 2024 Dhanasekar K. All rights reserved.
//

import Foundation


@objcMembers
public class Base64Converter: NSObject {
    
    static public func base64Decode(string: String) -> Data? {
        return Data(base64Encoded: string)
    }
}

// ===============

@objcMembers
public class ZSSORSAUtil: NSObject {
    
    /// RSA Key type.
    public let keyType: CFString
    
    /// RSA Key length in bits.
    public let keySizeInBits: AnyObject
    
    /// kSecAttrApplicationTag
    public let publicTag: Data?
    /// kSecAttrApplicationTag
    public let privateTag: Data?
    
    /// Server public key
    public let serverPublicTag: Data?
    
    var privateKeyString: Data?
    var publicKeyString: Data?
    
    public init(
        publicTag: String,
        privateTag: String,
        serverPublicTag: String
    ) {
        self.publicTag = publicTag.data(using: .utf8)
        self.privateTag = privateTag.data(using: .utf8)
        self.serverPublicTag = publicTag.data(using: .utf8)
        self.keySizeInBits = 2048 as AnyObject
        self.keyType = kSecAttrKeyTypeRSA
    }
    
    public init(
        publicTag: String,
        privateTag: String,
        serverPublicTag: String,
        keyType: CFString = kSecAttrKeyTypeRSA,
        keySizeInBits: Int = 2048
    ) {
        self.publicTag = publicTag.data(using: .utf8)
        self.privateTag = privateTag.data(using: .utf8)
        self.serverPublicTag = publicTag.data(using: .utf8)
        self.keySizeInBits = keySizeInBits as AnyObject
        self.keyType = keyType
    }
}

extension ZSSORSAUtil {
    
    /// Generates a pair of RSA keys and returns their base64-encoded representations.
    /// - Returns: A tuple containing the base64-encoded private and public key, or nil if key generation fails.
    public func generateKeyPair() {
        
        deleteOldKeys()
        
        // Attributes for the public key
        var publicKeyAttrs: [CFString: Any] = [
            kSecAttrIsPermanent: true,
            kSecClass: kSecClassKey,              // Key class is a generic key
            kSecReturnData: true,                 // Return the key data
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked // Accessible when device unlocked.
            // NOTE: If we don't mention kSecAttrAccessible by default it will be kSecAttrAccessibleWhenUnlocked
        ]
        if let publicTag {
            // Assign a tag for the key
            publicKeyAttrs[kSecAttrApplicationTag] = publicTag
        }
        
        // Attributes for the private key
        var privateKeyAttrs: [CFString: Any] = [
            kSecAttrIsPermanent: true,
            kSecClass: kSecClassKey,
            kSecReturnData: true,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked
        ]
        
        if let privateTag {
            // Assign a tag for the key
            privateKeyAttrs[kSecAttrApplicationTag] = privateTag
        }
        
        // Generate key pair
        var publicKey, privateKey: SecKey?
        
        let keyPairAttrs: [CFString: Any] = [
            kSecAttrKeyType: keyType,             // Specify RSA as the key type
            kSecAttrKeySizeInBits: keySizeInBits, // Specify key size
            kSecPublicKeyAttrs: publicKeyAttrs,   // Public key attributes
            kSecPrivateKeyAttrs: privateKeyAttrs  // Private key attributes
        ]
        
        let statusCode = SecKeyGeneratePair(keyPairAttrs as CFDictionary, &publicKey, &privateKey)
        
        // Check if the key pair generation was successful
        guard statusCode == noErr, let publicKeyRef = publicKey, let privateKeyRef = privateKey else {
            debugPrint("Error generating key pair: \(String(describing: statusCode))")
            return
        }
                        
        if let publicKeyData = SecKeyCopyExternalRepresentation(publicKeyRef, nil) as Data? {
            publicKeyString = publicKeyData
        }
        
        if let privateKeyData = SecKeyCopyExternalRepresentation(privateKeyRef, nil) as Data? {
            privateKeyString = privateKeyData
        }
    }
    
    @discardableResult
    public func saveServerKeyToKeychain(_ keyString: String) -> Bool {
        
        guard let keyData = Data(base64Encoded: keyString) else {
            return false
        }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecValueData: keyData,
            kSecAttrIsPermanent: true,
            kSecAttrApplicationTag: serverPublicTag
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving server key to keychain: \(status)")
            return false
        }
        return true
    }
    
    public func getServerPublicKey() -> SecKey? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag: serverPublicTag,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var publicKey: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &publicKey)
        
        guard status == errSecSuccess, let publicKey = publicKey else {
            return nil
        }
        return publicKey as! SecKey?
    }
}

extension ZSSORSAUtil {
    
    public func deleteOldKeys() {
        
        var queryPublicKey: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: keyType,
        ]
        if let publicTag {
            queryPublicKey[kSecAttrApplicationTag] = publicTag
        }
        
        var queryPrivateKey: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: keyType,
        ]
        if let privateTag {
            queryPrivateKey[kSecAttrApplicationTag] = privateTag
        }
        
        let privateKeyStatus = SecItemDelete(queryPrivateKey as CFDictionary)
        if privateKeyStatus != noErr && privateKeyStatus != errSecItemNotFound {
            print("Error removing private key, OSStatus == \(privateKeyStatus)")
        }
        
        // Delete the public key.
        let publicKeyStatus = SecItemDelete(queryPublicKey as CFDictionary)
        if publicKeyStatus != noErr && publicKeyStatus != errSecItemNotFound {
            print("Error removing public key, OSStatus == \(publicKeyStatus)")
        }
    }
    
    public func getPublicKeyForServer() -> String {
        self.getPublicKeyForServerAsData(getPublicKeyRef()?.toData())
    }
    
    public func getServerPublicKeyAsString(_ publicSecKey: SecKey?) -> String {
        self.getPublicKeyForServerAsData(publicSecKey?.toData())
    }
    
    public func getPublicKeyForServerAsData(_ publicKeyData: Data?) -> String {
        let oidData = ASN1.rsaOID()
        let bitstringSequence = ASN1.wrap(type: 0x03, followingData: publicKeyData ?? Data())
        
        let oidSequence = ASN1.wrap(type: 0x30, followingData: oidData)
        
        let X509Sequence = ASN1.wrap(type: 0x30, followingData: oidSequence + bitstringSequence)
        return X509Sequence.base64EncodedString()
    }
}


extension ZSSORSAUtil {
    
    public func getPrivateKeyRef() -> SecKey? {
        var query: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecReturnRef: true,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
            kSecAttrKeySizeInBits: keySizeInBits,
            kSecAttrKeyType: keyType,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ]
        
        if let privateTag {
            query[kSecAttrApplicationTag] = privateTag
        }
        
        var privateKey: AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, &privateKey)
        
        guard status == errSecSuccess, let privateKey = privateKey else {
            return nil
        }
        return privateKey as! SecKey?
    }
    
    public func getPublicKeyRef() -> SecKey? {
        var query: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecReturnRef: true,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
            kSecAttrKeySizeInBits: keySizeInBits,
            kSecAttrKeyType: keyType,
            kSecAttrKeyClass: kSecAttrKeyClassPublic
        ]
        
        if let publicTag {
            query[kSecAttrApplicationTag] = publicTag
        }
        
        var publicKey: AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, &publicKey)
        
        guard status == errSecSuccess, let publicKey = publicKey else {
            return nil
        }
        return publicKey as! SecKey?
    }
}

extension ZSSORSAUtil {
    
    public func rsaDecrypt(with data: Data) -> String? {
        guard let key = getPrivateKeyRef() else {
            return nil
        }
        let cipherBufferSize = SecKeyGetBlockSize(key)
        var keyBufferSize = data.count
        var bits = Data(count: keyBufferSize)
        
        let sanityCheck = bits.withUnsafeMutableBytes { decryptedBytes in
            data.withUnsafeBytes { encryptedBytes in
                SecKeyDecrypt(key, .PKCS1, encryptedBytes.baseAddress!, cipherBufferSize, decryptedBytes.baseAddress!, &keyBufferSize)
            }
        }
        guard sanityCheck == errSecSuccess else {
            print("Error decrypting data: \(sanityCheck)")
            return nil
        }
        bits.count = keyBufferSize
        return String(data: bits, encoding: .utf8)
    }
}

fileprivate struct ASN1 {
    static func wrap(type: UInt8, followingData: Data) -> Data {
        var adjustedFollowingData = followingData
        if type == 0x03 {
            adjustedFollowingData = Data([0]) + followingData // add prefix 0
        }
        let lengthOfAdjustedFollowingData = adjustedFollowingData.count
        let first: UInt8 = type
        var bytes = [UInt8]()
        if lengthOfAdjustedFollowingData <= 0x80 {
            let second: UInt8 = UInt8(lengthOfAdjustedFollowingData)
            bytes = [first, second]
        } else if lengthOfAdjustedFollowingData > 0x80 && lengthOfAdjustedFollowingData <= 0xFF {
            let second: UInt8 = UInt8(0x81)
            let third: UInt8 = UInt8(lengthOfAdjustedFollowingData)
            bytes = [first, second, third]
        } else {
            let second: UInt8 = UInt8(0x82)
            let third: UInt8 = UInt8(lengthOfAdjustedFollowingData >> 8)
            let fourth: UInt8 = UInt8(lengthOfAdjustedFollowingData & 0xFF)
            bytes = [first, second, third, fourth]
        }
        return Data(bytes) + adjustedFollowingData
    }

    static func rsaOID() -> Data {
        var bytes = [UInt8]()
        bytes = [0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00]
        return Data(bytes)
    }
}


fileprivate extension SecKey {
    func toData() -> Data? {
        var error:Unmanaged<CFError>?
        return SecKeyCopyExternalRepresentation(self, &error) as? Data
    }
}
