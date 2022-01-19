//
//  JWT.swift
//  httpstest
//
//  Created by wu ted on 2021/12/9.
//

import Foundation
import CryptoKit

extension Data {
    func urlSafeBase64EncodedString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

  struct Query_Reg_Sta_Payload: Encodable {
    var ID = "0d43bacc-abcd-49b2-8825-ae21c0e46783"
    var TYPE = "A"
//    init(id:String , type :String){
//        self.ID = id
//        self.TYPE = type
//    }
    
}
 struct Reg_Payload: Encodable {
    var ID = "0d43bacc-abcd-49b2-8825-ae21c0e46783"
    var ECDSAPUBKEY = "_ECDSA"
    var ECDHPUBKEY = "_ECDH"
    var FCMTOKEN = "FCM_Token"
    var TIME = "2022"
    var NOTE =  "Authenticator_DisplyName"
    var TYPE = "A"

}
struct Query_Bind_Stat_Payload:Encodable{
    var AID = "0d43bacc-abcd-49b2-8825-ae21c0e46783"
    var TIME = "time"
    
}

struct Bind_Payload:Encodable{
    var AID = "0d43bacc-abcd-49b2-8825-ae21c0e46783"
    var DID = "e"
    var TIME = "time"
}

struct dereg_Payload : Encodable{
    var ID = "0d43bacc-abcd-49b2-8825-ae21c0e46783"
    var TYPE = "A"
    var TIME = "time"
}

struct heartBeat_Payload:Encodable{
    var AID = "0d43bacc-abcd-49b2-8825-ae21c0e46783"
    var IP = ""
    var PORT = "7890"
    var TIME = "time"
}

class  genJWT{
    
    struct Header: Encodable {
        let alg = "HS256"
        let typ = "JWT"
    }

    let secret = "your-256-bit-secret"
    
    func start(_ payloadBase64String : String) -> String{
        
        let privateKey = SymmetricKey(data: secret.data(using: .utf8)!)

        let headerJSONData = try! JSONEncoder().encode(Header())
        let headerBase64String = headerJSONData.urlSafeBase64EncodedString()

//        let payloadJSONData = try! JSONEncoder().encode(Query_Reg_Sta_Payload())
//        let payloadBase64String = payloadJSONData.urlSafeBase64EncodedString()

        let toSign = (headerBase64String + "." + payloadBase64String).data(using: .utf8)!

        let signature = HMAC<SHA256>.authenticationCode(for: toSign, using: privateKey)
        let signatureBase64String = Data(signature).urlSafeBase64EncodedString()
        let token = [headerBase64String, payloadBase64String, signatureBase64String].joined(separator: ".")
//        print(token)
        return token
        
    }
    

    
}
