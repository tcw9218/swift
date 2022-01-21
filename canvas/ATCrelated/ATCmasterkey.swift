

import Foundation
import CryptoKit // ios 13

class ATCmasterKey{

   
    var ATCmasterGenImpl:@convention(c)() ->Int32 = {
        //MARK: - gen a key(SYM type)
        let key = SymmetricKey(size: .bits256)
        let keyb32 = key.withUnsafeBytes {
            return Data(Array($0))
        }
        let keyb = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        keyb.initialize(repeating: 0, count: 32)
        keyb32.copyBytes(to: keyb, count: 32)
        
     //  MARK: - save the key to keychain
        let tag = ("masterkey").data(using: .utf8)!
        let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                                       kSecValueData as String: keyb32]
        //kSecValueData  kSecValueRef
        let status = SecItemAdd(addquery as CFDictionary, nil)
        print(status)
        guard status == errSecSuccess else { return 1}
        print("succeed")
        return 0
        
    }
    var ATCmasterDesImpl:@convention(c)() ->Int32 = {
        let tag = ("masterkey").data(using: .utf8)!
        let deletequery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag]
        let deletestatus = SecItemDelete(deletequery as CFDictionary)
        if ( deletestatus == errSecSuccess ){
            print("delete masterkey success")
            return 0
        }else{
            return 1
        }
        
    }
    
    var ATCmasKeyState :@convention(c)( _ state : UnsafeMutablePointer<UInt8>?) ->Int32 = {state in
            if let state = state{
            let tag = ("masterkey").data(using: .utf8)!
            let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                        kSecAttrApplicationTag as String: tag,
                                        kSecReturnData as String: true       ]
            var item: CFTypeRef?
            var status = SecItemCopyMatching(query as CFDictionary, &item)
            if status == errSecSuccess{
                state[0] = 1
                return 0
            }else{
                state[0] = 0
                return 1}
        }else{
            state?[0] = 0
            return 1
        }
    }
    var ATCmaskeyEncryptImpl :@convention(c)( _ dataLen : UInt16 , _ dataIn : UnsafeMutablePointer<UInt8>? , _ dataOut: UnsafeMutablePointer<UInt8>?) -> Int32  = {
        dataLen , dataIn ,dataOut in
        if let dataIn = dataIn{
            let tag = ("masterkey").data(using: .utf8)!
            let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                        kSecAttrApplicationTag as String: tag,
                                        kSecReturnData as String: true       ]
            var item: CFTypeRef?
            var statusRetr = SecItemCopyMatching(query as CFDictionary, &item)
            if statusRetr == errSecSuccess
            {
            let maskey = item as! Data
//            let base64masKey = keyRetr.base64EncodedString()
//            let maskey = Data(base64Encoded: base64masKey)! // Data type
            var maskeyptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
            maskeyptr.initialize(repeating: 0, count: 32)
            maskey.copyBytes(to: maskeyptr, count: 32)
                
            let iv = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
            iv.initialize(repeating: 0, count: 16)
                
            blockcipher_onestep(CIPHER_AES256, MODE_CBC, 1, 0, 32, maskeyptr, 16, iv, UInt32(dataLen), dataIn, dataOut)
                return 0}
            else{
                print("master Encrypt SecItemCopyMatching error")
                return 1
            }
        }else{
            print("master Encrypt  pointer error")
            return 1
        }
        
    }
    
    var ATCmaskeyDecryptImpl :@convention(c)( _ dataLen : UInt16 , _ dataIn : UnsafeMutablePointer<UInt8>? , _ dataOut: UnsafeMutablePointer<UInt8>?) -> Int32  = {
        dataLen , dataIn ,dataOut in
        if let dataIn = dataIn{
            let tag = ("masterkey").data(using: .utf8)!
            let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                        kSecAttrApplicationTag as String: tag,
                                        kSecReturnData as String: true       ]
            var item: CFTypeRef?
            var statusRetr = SecItemCopyMatching(query as CFDictionary, &item)
            if statusRetr == errSecSuccess
            {
            let maskey = item as! Data
            var maskeyptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
            maskeyptr.initialize(repeating: 0, count: 32)
            maskey.copyBytes(to: maskeyptr, count: 32)
                
            let iv = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
            iv.initialize(repeating: 0, count: 16)
                
            blockcipher_onestep(CIPHER_AES256, MODE_CBC, 0, 0, 32, maskeyptr, 16, iv, UInt32(dataLen), dataIn, dataOut)                                //
                return 0}
            else{
                print("master Decrypt SecItemCopyMatching error")
                return 1
            }
        }else{
            print("master Decrypt pointer error")
            return 1
        }
        
    }
    
    
    
    
}
