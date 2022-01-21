//
//  ATCecdh.swift
//  ATC
//
//  Created by wu ted on 2022/1/4.
//

import Foundation
import CryptoKit

class ATCecdh{
    var ATC_ecdh_GenImpl :@convention(c)(  _ credential : UnsafeMutablePointer<UInt8>?,_ publickey : UnsafeMutablePointer<UInt8>?) ->Int32 = { credential , publickey in
        if let credential = credential , let publickey = publickey {
            //crypstal init
            let cry_ini = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                      cry_ini.initialize(repeating: 0, count: 32)
                      crystal_init(cry_ini, 32)
            
            //MARK: check if ecdh is exist
            let tag = ("ecdhkey").data(using: .utf8)!
            let ecdhquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                        kSecAttrApplicationTag as String: tag,
                                        kSecReturnData as String: true       ]
            var item: CFTypeRef?
            var statusRetr = SecItemCopyMatching(ecdhquery as CFDictionary, &item)
            if statusRetr == errSecSuccess{
                print("ecdhkey is exist")
                let deletestatusEcdh = SecItemDelete(ecdhquery as CFDictionary)
                if(deletestatusEcdh == errSecSuccess){
                    print("delete ecdhkey")
                }
            }
              //random as privatekey
                      let privkey = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
            let privkey_status = SecRandomCopyBytes(kSecRandomDefault,32,privkey)
           
            if privkey_status == errSecSuccess {
                 Data(bytes: privkey, count: 32)
                
                publickey.initialize(repeating: 0, count: 64)
                ecdsa_gen_keypair(ECP_DP_NIST_P256, privkey ,publickey)
//MARK: gen self ecdhkey to encrypt
               let key = SymmetricKey(size: .bits256)
               let keyb32 = key.withUnsafeBytes {
                   return Data(Array($0))
               }
             
               let keyptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                keyptr.initialize(repeating: 0, count: 32)
               keyb32.copyBytes(to:keyptr, count: 32)
               
//MARK:  save ecdhkey in keychain
               
               let addqueryecdh: [String: Any] = [kSecClass as String: kSecClassKey,
                                              kSecAttrApplicationTag as String: tag,
                                              kSecValueData as String: keyb32]
                let statusECDH = SecItemAdd(addqueryecdh as CFDictionary, nil)
           
                if statusECDH == errSecSuccess{
                    print("add success")
                }else{
                    print("add fail")
                }
           
               let iv = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
               iv.initialize(repeating: 0, count: 16)
//MARK:  encrypt ecdsa nonrk privatekey
               blockcipher_onestep(CIPHER_AES256, MODE_CBC, 0, 0, 32, keyptr, 16, iv, 32, privkey, credential)
               
               cry_ini.deallocate()
               
               return 0
            }else{
                print("ecdh privkey error")
                return 1}
        }else{
            print("ATC_ecdsa_nonrkGenImpl input  ptr error")
            return 1
        }
    }
    
    
    var ATC_ecdh_deriveImpl: @convention(c)( _ credentialA : UnsafeMutablePointer<UInt8>? ,  _ publickeyB : UnsafeMutablePointer<UInt8>? ,  _ sharedsecret : UnsafeMutablePointer<UInt8>?) ->Int32 = {
        credentialA , publickeyB , sharedsecret in
        if let credentialA = credentialA ,let publickeyB = publickeyB ,let sharedsecret = sharedsecret{
            let tag = ("ecdhkey").data(using: .utf8)!
            let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                        kSecAttrApplicationTag as String: tag,
                                        kSecReturnData as String: true       ]
            var item: CFTypeRef?
            var statusRetr = SecItemCopyMatching(query as CFDictionary, &item)
            if statusRetr == errSecSuccess
            {
                //CRYPTAL INIT
                let cry_ini = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                cry_ini.initialize(repeating: 0, count: 32)
                crystal_init(cry_ini, 32)
                //nonrk
                let ecdhkey = item as! Data
                var ecdhkeyptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                ecdhkeyptr.initialize(repeating: 0, count: 32)
                ecdhkey.copyBytes(to: ecdhkeyptr, count: 32)
                //decrypt credential to nonrkkey
                let iv = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
                iv.initialize(repeating: 0, count: 16)
                let ecdh_prikeyptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                ecdh_prikeyptr.initialize(repeating: 0, count: 32)
                blockcipher_onestep(CIPHER_AES256, MODE_CBC, 1, 0, 32, ecdhkeyptr, 16, iv, 32, credentialA, ecdh_prikeyptr)
              
                sharedsecret.initialize(repeating: 0, count: 32)// only x coordinate
            ecdh_derive_shared_secret(ECP_DP_NIST_P256, ecdh_prikeyptr, 32, publickeyB, sharedsecret)
//                print("sharedsecret")
//                for j in 0..<32{
//                    let a = sharedsecret[j]
//                    let st = String(format:"%02X", a)
//                    print("\(st)",terminator: " ")
//                   // print(sharedsecret[i],terminator: " ")
//                }
            return 0
            }else{
                print("ecdh priv_status error")
                return 1
            }
        }
        else{
            print("ATC_ecdh_deriveImpl input ptr error")
            return 1
        }
    }
    
    
    
    
}
