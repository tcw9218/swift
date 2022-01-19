

import Foundation
class ATCattKey{
    
    var ATC_attKeySetImpl:@convention(c)(   _ dataInPri : UnsafeMutablePointer<UInt8>?,_ dataInPub : UnsafeMutablePointer<UInt8>?)->Int32 = {dataInPri, dataInPub in
            
        if let dataInPri = dataInPri ,let dataInPub = dataInPub{
            var attkeyPri = Data(bytes: dataInPri , count: 32)
            var tagPri = ("attkeypri").data(using: .utf8)!
            var attkeyPub = Data(bytes: dataInPub , count: 64)
            var tagPub = ("attkeypub").data(using: .utf8)!
            
            let addqueryPri: [String: Any] = [kSecClass as String: kSecClassKey,
                                           kSecAttrApplicationTag as String: tagPri,
                                           kSecValueData as String: attkeyPri]
            
            let addqueryPub: [String: Any] = [kSecClass as String: kSecClassKey,
                                           kSecAttrApplicationTag as String: tagPub,
                                           kSecValueData as String: attkeyPub]
            //kSecValueData  kSecValueRef
            let statusPri = SecItemAdd(addqueryPri as CFDictionary, nil)
            let statusPub = SecItemAdd(addqueryPub as CFDictionary, nil)
            guard statusPri == errSecSuccess && statusPub == errSecSuccess else { return 1}
            print("attkey set succceed")
            return 0
        }else{
            return 1
        }
    }
    
    
    var ATC_attKeyDestroyImpl:@convention(c)() ->Int32 = {
        var tagPri = ("attkeypri").data(using: .utf8)!
        var tagPub = ("attkeypub").data(using: .utf8)!
        let deletequeryPri: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tagPri]
        let deletequeryPub: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tagPub]
        let deletestatusPri = SecItemDelete(deletequeryPri as CFDictionary)
        let deletestatusPub = SecItemDelete(deletequeryPub as CFDictionary)
        if ( deletestatusPri == errSecSuccess && deletestatusPub == errSecSuccess ){
            print("delete attkey success")
            return 0
        }else{
            return 1
        }
    }
    
    var ATC_attKeyStateImpl :@convention(c)(  _ state : UnsafeMutablePointer<UInt8>?) ->Int32 = { state in
            if let state = state{
            var tag = ("attkeypri").data(using: .utf8)!
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
    
    
    var ATC_attkeySignImpl :@convention(c)( _ digest : UnsafeMutablePointer<UInt8>?, _ signature : UnsafeMutablePointer<UInt8>?) ->Int32 = {digest , signature in
        
        if let digest = digest ,let signature = signature{
            var tag = ("attkeypri").data(using: .utf8)!
            let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                        kSecAttrApplicationTag as String: tag,
                                        kSecReturnData as String: true       ]
            var item: CFTypeRef?
            var status = SecItemCopyMatching(query as CFDictionary, &item)
            if status == errSecSuccess
            {
                let attkey = item as! Data
                var attkeyptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                    attkeyptr.initialize(repeating: 0, count: 32)
                attkey.copyBytes(to: attkeyptr, count: 32)
                // gen random
                var random = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                let randomstatus = SecRandomCopyBytes(kSecRandomDefault,32,random)
                if randomstatus == errSecSuccess {
                    let data = Data(bytes: random, count: 32)
                }
                
                var seed = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)// no used
                var sig_r = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                var sig_s = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                ecdsa_sign(ECP_DP_NIST_P256, sig_r, sig_s, attkeyptr, UInt32(attkey.count), digest, 32, random, seed)
            
                signature.initialize(from: sig_r, count: 32)
                signature.advanced(by: 32).initialize(from: sig_s, count: 32)
            return 0
            }else{
                print("ATTkey status fail")
                return 1
            }
        }else{
            print("digest or signature pointer error")
            return 1
        }
        
    }
    
    var ATC_rng :@convention(c)(_ length : UInt16 , _ random : UnsafeMutablePointer<UInt8>?) -> Int32
    = { length, random in
        //var bytes = [Int8](repeating: 0, count: Int(length))
        //let status = SecRandomCopyBytes(kSecRandomDefault,Int(length),&bytes)
        if let random = random
        {
            let status = SecRandomCopyBytes(kSecRandomDefault,Int(length),random)
            if status == errSecSuccess {
                let data = Data(bytes: random, count: Int(length))
                
                return 0
            }else {
                print("random status error")
                return 1
            }
        }else{
            print("random pointer error")
            return 1
        }
    }
}
//Security.arc4random()
