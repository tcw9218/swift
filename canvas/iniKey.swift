//
//  ini_CBridging.swift
//  ATC
//
//  Created by wu ted on 2022/1/6.
//

import Foundation

class iniKey{
    let aaguid =  "504d71494e4c3841455555445a677357".hexDecodedData()//16 bytes
    let certificate = "3082022d308201d2a003020102020101300a06082a8648ce3d040302308187310b3009060355040613025457310f300d06035504080c065461697065693112301006035504070c09536f6d65776865726531163014060355040a0c0d576953454355524520496e632e3120301e06092a864886f70d010901161161646d696e406578616d706c652e6f72673119301706035504030c10576953454355524520526f6f74204341301e170d3231303132383038323732305a170d3331303132363038323732305a308181310b3009060355040613025457310f300d06035504080c0654616970656931163014060355040a0c0d576953454355524520496e632e31223020060355040b0c1941757468656e74696361746f72204174746573746174696f6e3125302306035504030c1c5769534543555245204649444f322041757468656e74696361746f723059301306072a8648ce3d020106082a8648ce3d03010703420004031ed6f3cdd60022c2625e1185ba2a07bb1a0a6c3c62b4a28a297b7897ce3d770dbfdf0cd2080356391d8448f65d9821b3fc14f7ebc07c556d0c13839f044648a3333031300c0603551d130101ff040230003021060b2b0601040182e51c01010404120c10504d71494e4c3841455555445a677357300a06082a8648ce3d0403020349003046022100a0b2bde9014eb5ecbf855e1e37b64d39de41bd08c860eedd49f22694cb57b8c20221009051470810abe893122cb5691fceeb3a7c2d0ec9c1e11390ecaab6445232e24b".hexDecodedData()  //561 bytes
    let twokeys = "031ed6f3cdd60022c2625e1185ba2a07bb1a0a6c3c62b4a28a297b7897ce3d770dbfdf0cd2080356391d8448f65d9821b3fc14f7ebc07c556d0c13839f044648f23292054c2f5414c35ae4571f84c99c159d0061391379f72b7084bf656edaba00000000454344534147454e".hexDecodedData()
    let att_privatekey = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
    let att_publickey = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
    let uuidptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
    
    
    let cert0ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: 561)
    var ptr = UnsafeMutablePointer<UInt16>.allocate(capacity: 1)
    var certptr2 = UnsafeMutablePointer<UInt8>.allocate(capacity: 561)
    
    var ASP : UnsafeMutablePointer<ASP_Data>
    var key_state = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
    
    
    
    init(_ asp : UnsafeMutablePointer<ASP_Data> ){
        self.ASP = asp
    }
    
    func setall(){
        let ATCattKey = ATCattKey()
        let ATCstorage = ATCstorage()
        let ATCmasterkey = ATCmasterKey()
        let ATCecdsa = ATCecdsa()
        let ATCecdh = ATCecdh()
        let ATCaessha = AESSHA()
        
        ATC_sha256Func = ATCaessha.ATC_SHA256Impl
        ATC_hmac256Func = ATCaessha.ATC_hmac256Impl
        
        ATC_storageSetFunc = ATCstorage.ATC_storageWriteImpl
        ATC_storageGetFunc = ATCstorage.ATC_storageReadImpl
        ATC_storageDeleteFunc = ATCstorage.ATC_storageDeleteImpl
        ATC_storageState = ATCstorage.ATC_storageStateImpl
        
        ATC_attkeyState = ATCattKey.ATC_attKeyStateImpl
        ATC_attkeySetFunc =  ATCattKey.ATC_attKeySetImpl
        ATC_rngFunc = ATCattKey.ATC_rng
        ATC_attkeyDestroyFunc = ATCattKey.ATC_attKeyDestroyImpl
        ATC_attkeySignFunc = ATCattKey.ATC_attkeySignImpl
        
        
        ATC_maskeyState = ATCmasterkey.ATCmasKeyState
        ATC_maskeyGenFunc = ATCmasterkey.ATCmasterGenImpl
        ATC_maskeyDesFunc = ATCmasterkey.ATCmasterDesImpl
        ATC_maskeyEncryptFunc = ATCmasterkey.ATCmaskeyEncryptImpl
        ATC_maskeyDecryptFunc = ATCmasterkey.ATCmaskeyDecryptImpl
        
        ATC_ecdh_GenFunc = ATCecdh.ATC_ecdh_GenImpl
        ATC_ecdh_deriveFunc = ATCecdh.ATC_ecdh_deriveImpl
        
        ATC_ecdsa_rkDestroyFunc = ATCecdsa.ATC_ecdsa_rkDestroyImpl
        ATC_ecdsa_rkGenFunc = ATCecdsa.ATC_ecdsa_rkGenImpl
        ATC_ecdsa_rkState = ATCecdsa.ATC_ecdsa_rkState
        ATC_ecdsa_rkSignFunc = ATCecdsa.ATC_ecdsa_rkSignImpl
        ATC_ecdsa_nonrkGenFunc = ATCecdsa.ATC_ecdsa_nonrkGenImpl
        ATC_ecdsa_nonrkSignFunc = ATCecdsa.ATC_ecdsa_nonrkSignImpl
        
        twokeys.copyBytes(to: att_publickey, count: 64)
        twokeys.advanced(by: 64).copyBytes(to: att_privatekey, count: 32)
        uuidptr.initialize(repeating: 0, count: 16)
        aaguid.copyBytes(to: uuidptr, count: 16)
        cert0ptr.initialize(repeating: 0, count: 561)
        certificate.copyBytes(to: cert0ptr, count: 561)
        ATC_ADP_store_set(3, 16, uuidptr)//aaguid
        ATC_ADP_store_set(4, 561, cert0ptr)
        key_state.initialize(repeating: 0, count: 1)
        //ATC_ADP_ecdsa256_attkey_destroy()
        ATC_ADP_ecdsa256_attkey_state(key_state)
        //ctap_handler_init(ASP)
        if(key_state.pointee == 0){
            //key set
            ATC_ADP_ecdsa256_attkey_set(att_privatekey, att_publickey)
            print("set attkey")
        }else{
            print("attkey is already existed")
        }
//        var aaguidppt = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
//        aaguidppt.initialize(repeating: 0, count: 16)
//        var aaguidlth = UnsafeMutablePointer<UInt16>.allocate(capacity: 1)
//        ATC_ADP_store_get(3,aaguidlth , aaguidppt)
//        for i in 0..<16{
//            print("aaguid :\(aaguidppt[i])")
//        }
//        att_publickey.deallocate()
//        att_privatekey.deallocate()
//        uuidptr.deallocate()
//        cert0ptr.deallocate()
//        certptr2.deallocate()
//        key_state.deallocate()
//        ptr.deallocate()
       
    }
    func ASPstate(){
        print("state:: \(ASP[0].state)")
    }
    func deletattkey(){
        ATC_ADP_ecdsa256_attkey_destroy()
    }
}

extension String {
  /// A data representation of the hexadecimal bytes in this string.
  func hexDecodedData() -> Data {
    // Get the UTF8 characters of this string
    let chars = Array(utf8)

    // Keep the bytes in an UInt8 array and later convert it to Data
    var bytes = [UInt8]()
    bytes.reserveCapacity(count / 2)

    // It is a lot faster to use a lookup map instead of strtoul
    let map: [UInt8] = [
      0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
      0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
      0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
    ]

    // Grab two characters at a time, map them and turn it into a byte
    for i in stride(from: 0, to: count, by: 2) {
      let index1 = Int(chars[i] & 0x1F ^ 0x10)
      let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
      bytes.append(map[index1] << 4 | map[index2])
    }

    return Data(bytes)
  }
}
