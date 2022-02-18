//
//  AESSHA.swift
//  canvas
//
//  Created by wu ted on 2022/1/11.
//

import Foundation

class AESSHA{
    
    var ATC_SHA256Impl:@convention(c)(  _ dataLen : UInt16 ,_ dataIn : UnsafeMutablePointer<UInt8>? , _ dataOut : UnsafeMutablePointer<UInt8>?)->Int32 = {dataLen, dataIn , dataOut in
        if let dataIn = dataIn , let dataOut = dataOut{
            
        //crypstal init
        let cryp_ini = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        cryp_ini.initialize(repeating: 0, count: 32)
        crystal_init(cryp_ini, 32)
            
        let digestlength = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        digestlength.initialize(repeating: 0, count: 1)
        hash_onestep(SHA2_256_TYPE, UInt32(dataLen), dataIn, digestlength, dataOut)
//
//        for data in 0..<32{
//           // print(dataOut[data])
//            let a = dataOut[data]
//            let st = String(format:"%02X", a)
//            //st += " is the hexadecimal representation of \(a)"
//            print("sha256digest:\(st)")
//        }
        return 0
        }else
        {
            print("sha256 data in out error")
            return 1
        }
    }
    
    var ATC_hmac256Impl:@convention(c)(  _ keyLen : UInt8 ,_ key : UnsafeMutablePointer<UInt8>?, _ dataLen : UInt16 ,_ dataIn : UnsafeMutablePointer<UInt8>? , _ dataOut : UnsafeMutablePointer<UInt8>?)->Int32 = {keyLen,key,dataLen, dataIn , dataOut in
        if let dataIn = dataIn , let dataOut = dataOut , let key = key{
            
        //crypstal init
        let cryp_ini = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        cryp_ini.initialize(repeating: 0, count: 32)
        crystal_init(cryp_ini, 32)
            
        let maclength = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
            maclength.initialize(repeating: 0, count: 1)
        hmac_onestep(SHA2_256_TYPE, UInt32(keyLen), key, UInt32(dataLen), dataIn, maclength, dataOut);
//        print("hmacdigest")
//        for data in 0..<32{
//           // print(dataOut[data])
//            let a = dataOut[data]
//            let st = String(format:"%02X", a)
//            //st += " is the hexadecimal representation of \(a)"
//            print("\(st)" , terminator:  " ")
//        }
//            print("")
        return 0
        }else
        {
            print("hmac data in out key error")
            return 1
            
        }
    }
}
