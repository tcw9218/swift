//
//  ATCecdsa.swift
//  ATC
//
//  Created by wu ted on 2022/1/3.
//
// ATC_ecdsa_nonrkGenImpl ,  ATC_ecdsa_nonrkSignImpl, ATC_ecdsa_rkGenImpl , ATC_ecdsa_rkSignImpl ,ATC_ecdsa_rkDestroyImpl ,ATC_ecdsa_rkState
import Foundation
import CryptoKit
class ATCecdsa {
//MARK: - ATC_ecdsa_nonrkGenImpl
    var ATC_ecdsa_nonrkGenImpl :@convention(c)( _ credential : UnsafeMutablePointer<UInt8>?,_ publickey : UnsafeMutablePointer<UInt8>?) ->Int32 = { credential , publickey in
        if let credential = credential , let publickey = publickey {
            //crypstal init
            let cryp_ini = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
            cryp_ini.initialize(repeating: 0, count: 32)
            crystal_init(cryp_ini, 32)
            
            //MARK: check if ecdsakey is exist
            let tag = ("nonrkkey").data(using: .utf8)!
            let ecdsaquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                        kSecAttrApplicationTag as String: tag,
                                        kSecReturnData as String: true       ]
            var item: CFTypeRef?
            var statusRetr = SecItemCopyMatching(ecdsaquery as CFDictionary, &item)
            if statusRetr == errSecSuccess{
                print("nonrkkey is exist")
                let deletestatusEcdsa = SecItemDelete(ecdsaquery as CFDictionary)
                if(deletestatusEcdsa == errSecSuccess){
                    print("delete nonrkkey")
                }
            }
    //random(as privatekey)
            let privkey = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
            let privkey_status = SecRandomCopyBytes(kSecRandomDefault,32,privkey)
            if privkey_status == errSecSuccess {
                
                Data(bytes: privkey, count: 32)
                publickey.initialize(repeating: 0, count: 64)
                ecdsa_gen_keypair(ECP_DP_NIST_P256, privkey ,publickey)
   //gen selfkey on encrypting
                let key = SymmetricKey(size: .bits256)
                let keyb32 = key.withUnsafeBytes {
                   return Data(Array($0))
                }
               let keyptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
               keyptr.initialize(repeating: 0, count: 32)
               keyb32.copyBytes(to: keyptr, count: 32)
               
    // save selfkey in keychain
               let tag = ("nonrkkey").data(using: .utf8)!
               let addqueryecdsa: [String: Any] = [kSecClass as String: kSecClassKey,
                                              kSecAttrApplicationTag as String: tag,
                                              kSecValueData as String: keyb32]
                let statusECDSA = SecItemAdd(addqueryecdsa as CFDictionary, nil)
                if statusECDSA == errSecSuccess{
                    print("add ecdsanonrk success")
                }else{
                    print("add ecdsanonrk fail")
                }
               let iv = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
               iv.initialize(repeating: 0, count: 16)
    // encrypt ecdsa nonrk privatekey to credentialkey
               blockcipher_onestep(CIPHER_AES256, MODE_CBC, 0, 0, 32, keyptr, 16, iv, 32, privkey, credential)
               
    
               return 0
            }else{
                print("nonrk privkey error")
                return 1}
        }else{
            print("ATC_ecdsa_nonrkGenImpl input  ptr error")
            return 1
        }
    }
//MARK: - ATC_ecdsa_nonrkSignImpl
    var ATC_ecdsa_nonrkSignImpl :@convention(c)(  _ credential : UnsafeMutablePointer<UInt8>?,_ digest : UnsafeMutablePointer<UInt8>? , _ signature : UnsafeMutablePointer<UInt8>?) ->Int32 = { credential , digest ,signature in
        if let credential = credential , let digest = digest , let signature = signature  {
            let tag = ("nonrkkey").data(using: .utf8)!
            let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                        kSecAttrApplicationTag as String: tag,
                                        kSecReturnData as String: true       ]
            var item: CFTypeRef?
            var statusRetr = SecItemCopyMatching(query as CFDictionary, &item)
            if statusRetr == errSecSuccess
            {
    //CRYPTAL INIT
                let cryp_ini = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                cryp_ini.initialize(repeating: 0, count: 32)
                crystal_init(cryp_ini, 32)
    //credkey
                let credkey = item as! Data
                var credkeyptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                credkeyptr.initialize(repeating: 0, count: 32)
                credkey.copyBytes(to: credkeyptr, count: 32)
    //decrypt credential to nonrkkey
                let iv = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
                iv.initialize(repeating: 0, count: 16)
                let nonrk_prikeyptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                nonrk_prikeyptr.initialize(repeating: 0, count: 32)
                blockcipher_onestep(CIPHER_AES256, MODE_CBC, 1, 0, 32, credkeyptr, 16, iv, 32, credential, nonrk_prikeyptr) //type ,mode,dir,padding,keylen,key,ivlen,iv,datalen,datain,dataout
    //sign
                var random = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                let randomstatus = SecRandomCopyBytes(kSecRandomDefault,32,random)
                if randomstatus == errSecSuccess {
                    let data = Data(bytes: random, count: 32)
                }
                var seed = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)// no used
                var sig_r = UnsafeMutablePointer<UInt8>.allocate(capacity: 32) //output
                var sig_s = UnsafeMutablePointer<UInt8>.allocate(capacity: 32) //output
                ecdsa_sign(ECP_DP_NIST_P256, sig_r, sig_s, nonrk_prikeyptr, 32, digest, 32, random, seed)
                
                signature.initialize(from: sig_r, count: 32)
                signature.advanced(by: 32).initialize(from: sig_s, count: 32)
                
                return 0
            }else{
                print("nonrkkey query_status error")
                return 1
            }
          
        }else{
            print("ATC_ecdsa_nonrkSignImpl input ptr error")
            return 1
        }
    }

//MARK: - ATC_ecdsa_rkGenImpl
    var ATC_ecdsa_rkGenImpl :@convention(c)( _ keyId : UInt16, _ publickey : UnsafeMutablePointer<UInt8>?) ->Int32 = { keyId , publickey in
        if  let publickey = publickey {
            //crypstal init
            let cryp_ini = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
            cryp_ini.initialize(repeating: 0, count: 32)
            crystal_init(cryp_ini, 32)
            //random as privkey
            let privkey = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
            publickey.initialize(repeating: 0, count: 64)//
            let privkey_status = SecRandomCopyBytes(kSecRandomDefault,32,privkey)
            if  privkey_status == errSecSuccess {
                 Data(bytes: privkey, count: 32)
                 ecdsa_gen_keypair(ECP_DP_NIST_P256, privkey ,publickey)

             // save rkprivkey in keychain
               let tag = ("rkkey"+String(keyId)).data(using: .utf8)!
               let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                              kSecAttrApplicationTag as String: tag,
                                              kSecValueData as String: privkey]
               
               return 0
            }else{
                print("ATC_ecdsa_rkGenImpl privkey_status error" )
                return 1}
        }else{
            print("ATC_ecdsa_rkGenImpl input  ptr error")
            return 1
        }
    }
//MARK: - ATC_ecdsa_rkSignImpl
    var ATC_ecdsa_rkSignImpl :@convention(c)(  _ keyId : UInt16, _ digest : UnsafeMutablePointer<UInt8>? , _ signature : UnsafeMutablePointer<UInt8>?) ->Int32 = { keyId,digest ,signature in
        if let digest = digest , let signature = signature  {
            
            let tag = ("rkkey"+String(keyId)).data(using: .utf8)!
            let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                        kSecAttrApplicationTag as String: tag,
                                        kSecReturnData as String: true       ]
            var item: CFTypeRef?
            var statusRetr = SecItemCopyMatching(query as CFDictionary, &item)
            if statusRetr == errSecSuccess
            {
    //CRYPTAL INIT
                let cryp_ini = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                cryp_ini.initialize(repeating: 0, count: 32)
                crystal_init(cryp_ini, 32)
    //rk privkey
                let rkkey = item as! Data
                var rkkeyptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                rkkeyptr.initialize(repeating: 0, count: 32)
                rkkey.copyBytes(to: rkkeyptr, count: 32)
    //sign
                var random = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                let randomstatus = SecRandomCopyBytes(kSecRandomDefault,32,random)
                if randomstatus == errSecSuccess {
                    let data = Data(bytes: random, count: 32)
                }
                var seed = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)// no used
                var sig_r = UnsafeMutablePointer<UInt8>.allocate(capacity: 32) //output
                var sig_s = UnsafeMutablePointer<UInt8>.allocate(capacity: 32) //output
                ecdsa_sign(ECP_DP_NIST_P256, sig_r, sig_s, rkkeyptr, 32, digest, 32, random, seed)
                
                signature.initialize(from: sig_r, count: 32)
                signature.advanced(by: 32).initialize(from: sig_s, count: 32)
                
                return 0
            }else{
                print("rkkey query_status error")
                return 1
            }
        }else{
            print("ATC_ecdsa_nonrkSignImpl input ptr error")
            return 1
        }
    }
    
    var ATC_ecdsa_rkState :@convention(c)(  _ keyId : UInt16, _ state : UnsafeMutablePointer<UInt8>? ) ->Int32 = { keyId,state  in
        if let state = state   {
            var tag = ("rkkey"+String(keyId)).data(using: .utf8)!
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
            print("ATC_ecdsa_rkStateImpl input ptr error")
            state?[0] = 0
            return 1
        }
    }
    
    var ATC_ecdsa_rkDestroyImpl :@convention(c)(  _ keyId : UInt16 ) ->Int32 = { keyId  in
        
        var tag = ("rkkey"+String(keyId)).data(using: .utf8)!
        let deletequeryPri: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag]
      
        let deletestatusPri = SecItemDelete(deletequeryPri as CFDictionary)
        print(deletestatusPri)
        if ( deletestatusPri == errSecSuccess ){
            
            print("ATC_ecdsa_rkDestroy success")
            return 0
        }else{
            return 1}
    }

}
