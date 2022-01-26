
//
//  processUdpData.swift
//  canvas
//
//  Created by wu ted on 2021/12/30.
//

import Foundation
import UIKit
import Network

class processUdpData{
    
    var data_in : Data
    var sendLength = 0
    var udpaddress : NWConnection?
    var istouched = false
//    @objc var ObservFACEid : FinalViewController? = nil
//    var observation: NSKeyValueObservation?

    let notify_userAround = Notification.Name("userIsAround")
//    init(_ ASP : UnsafeMutablePointer<ASP_Data>,_ data : Data , _ btn :UIButton ,_ btn2 :UIButton , _ nwdestination : NWConnection)
    
    init(_ data : Data , _ nwdestination : NWConnection /*, ObservFACEid :FinalViewController */){
//        self.ObservFACEid = ObservFACEid
        self.data_in = data
        self.udpaddress = nwdestination
       
        NotificationCenter.default.addObserver(self, selector: #selector(checkTapbtn(notification:)), name: notify_userAround, object: nil)
        print("udpprocess init")
        
    }
    
    
    
    
    @objc func checkTapbtn(notification: NSNotification){
        print("received")
            istouched = true
        
    }
    deinit{
        print("udpprocess deinit")
    }
    func start()->Data{
       

        let number = data_in.count - 116 //  offset(112) + CRC (4)
        let receive_payload = UnsafeMutablePointer<UInt8>.allocate(capacity:  number)
        receive_payload.initialize(repeating: 0, count: number)
        data_in.advanced(by: 112).copyBytes(to: receive_payload, count: number)
        let ctap_cmd = receive_payload[0]
//        let ctap_length = ( UInt16((receive_payload[1] & 0xFF)) << 8 | UInt16((receive_payload[2] & 0xFF)) )
        let ctap_msg = UnsafeMutablePointer<UInt8>.allocate( capacity: number - 3)//remove cmd length
        ctap_msg.initialize(from: receive_payload.advanced(by: 3), count: number - 3)
        
        let buf_ptr = UnsafeMutablePointer<UInt8>.allocate( capacity: number - 3)
       // var buf : [UInt8]
        
         
//        print("ctap_msg")
//        print("numer ::\(number-3)")
//        for i in 0..<number-3{
//            let a = ctap_msg[i]
//            let st = String(format: "%02X", a)
//            print("\(st)", terminator: " ")
//        }
//        print("")
        
//        print("buf")
        for i in 0..<(number-3){
            buf_ptr[i] = ctap_msg[i] // copy important cuz ctap_msh might be changed
//            let a = buf_ptr[i]
//            let st = String(format: "%02X", a)
//            print(st , terminator: " ")
        }
//        print("")
        
        let sendbuf = UnsafeMutablePointer<UInt8>.allocate(capacity: 2048)
        sendbuf.initialize(repeating: 0, count: 2048)
        let cbor0 = UnsafeMutablePointer<UInt8>.allocate(capacity: 120)
        cbor0.initialize(repeating: 0, count: 120)
// MARK: CBOR
        if(ctap_cmd == 0x90){
            
            var iCborResult = authTronCore_cbor_cmd_handler(GLOASP.gloasp, ctap_msg, UInt16(number - 3), sendbuf.advanced(by: 112+3), 2048, 0)
            
//   MARK: UP
            if(iCborResult == ((0x10000) | 0 )){ // UP
              
                var dataout : [UInt8] = []
                for _ in 0..<120{  // length 116+ 4
                    dataout.append(0)
                }

                let cbor00 = Notification.Name("cbor00")
                NotificationCenter.default.post(name: cbor00, object: nil)
       
                while(!istouched || !GLOASP.FACEidresult){//if false send keep alive

                    print("user not around",terminator: "")

                    dataout[0] = 0x78
                    dataout[1] = 0x00
                    dataout[112] = 0xbb
                    dataout[113] = 0x00
                    dataout[114] = 0x01
                    dataout[115] = 0x02


                    udpaddress!.send(content: dataout, completion:NWConnection.SendCompletion.contentProcessed(
                            ({(NWError) in
                                if (NWError == nil) {
                                //print("haaallllttttt")
                                  //print("usernot around data ::\(dataout)")
                                }else {print("ERROR! Error when data sending inside. NWError: n (NWError!)")}
                               })))
                    sleep(1)

                }

                
                iCborResult = authTronCore_cbor_cmd_handler(GLOASP.gloasp, buf_ptr, UInt16(number - 3), sendbuf.advanced(by: 112+3), 2048, 3)
               
                print("iCborResult:\(iCborResult)")
                print("has pressed button")
                //print("sendddingbuf::\(sendbuf[115])")

                //print(" pin set ::: \(iCborResult)")
                let sendLength = iCborResult + 3 + 116
                self.sendLength = Int(sendLength)
                sendbuf[0] = UInt8((sendLength >> 0) & 0xFF);
                sendbuf[1] = UInt8((sendLength >> 8) & 0xFF);
                sendbuf[112 + 0] = ctap_cmd;
                sendbuf[112 + 1] = UInt8((iCborResult >> 8) & 0xFF);
                sendbuf[112 + 2] = UInt8((iCborResult >> 0) & 0xFF);
                print("UP send after touched")
                istouched = false
                
            }
//   MARK: UV
            else if(iCborResult == ((0x10000) | 1)){
                print("UVUVU")
                  var dataout : [UInt8] = []
                  for _ in 0..<120{  // length 116+ 4
                      dataout.append(0)
                  }

                  let UV = Notification.Name("cbor00uv")
                  NotificationCenter.default.post(name: UV, object: nil)
         
                  while(!GLOASP.FACEidresult){

                      print("uv",terminator: "")
//                      observation = observe(\.ObservFACEid.FACEidresult, options:[.old, .new]) { (object, change) in
//                                 print("Value:\(String(describing: object.ObservFACEid.FACEidresult))")
//                                 print("Value:\(String(describing: change.newValue)))")
//                             }

                      dataout[0] = 0x78
                      dataout[1] = 0x00
                      dataout[112] = 0xbb
                      dataout[113] = 0x00
                      dataout[114] = 0x01
                      dataout[115] = 0x02


                      udpaddress!.send(content: dataout, completion:NWConnection.SendCompletion.contentProcessed(
                              ({(NWError) in
                                  if (NWError == nil) {
                                  //print("haaallllttttt")
                                    //print("usernot around data ::\(dataout)")
                                  }else {print("ERROR! Error when data sending inside. NWError: n (NWError!)")}
                                 })))
                      sleep(1)

                  }

                  
                  iCborResult = authTronCore_cbor_cmd_handler(GLOASP.gloasp, buf_ptr, UInt16(number - 3), sendbuf.advanced(by: 112+3), 2048, 2)
                  print("has pressed button")

                  let sendLength = iCborResult + 3 + 116
                  self.sendLength = Int(sendLength)
                  sendbuf[0] = UInt8((sendLength >> 0) & 0xFF);
                  sendbuf[1] = UInt8((sendLength >> 8) & 0xFF);
                  sendbuf[112 + 0] = ctap_cmd;
                  sendbuf[112 + 1] = UInt8((iCborResult >> 8) & 0xFF);
                  sendbuf[112 + 2] = UInt8((iCborResult >> 0) & 0xFF);
                  print("UV send after touched")
                
            }
            else if(iCborResult > 0){
                let sendLength = iCborResult + 3 + 116
                self.sendLength = Int(sendLength)
               // let sendbuf = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(sendLength))
                sendbuf[0] = UInt8((sendLength >> 0) & 0xFF);
                sendbuf[1] = UInt8((sendLength >> 8) & 0xFF);
                sendbuf[112 + 0] = ctap_cmd;
                sendbuf[112 + 1] = UInt8((iCborResult >> 8) & 0xFF);
                sendbuf[112 + 2] = UInt8((iCborResult >> 0) & 0xFF);
            }else{
                print("CBOR return <0")
            }

        }
        else if(ctap_cmd == 0x83 ){ //U2F
            print("U2F")
            
            
            
            
          
        }
        var dataout : [UInt8] = []
        
        for i in 0..<sendLength{
            
            dataout.append (sendbuf[Int(i)])
        }
       
        receive_payload.deallocate()
        ctap_msg.deallocate()
        buf_ptr.deallocate()
        sendbuf.deallocate()
        cbor0.deallocate()
        return Data(dataout)
    }

    
}

