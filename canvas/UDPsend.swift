//
//  UDPsend.swift
//  ATMtest
//
//  Created by wu ted on 2022/2/21.
//  Copyright © 2022 com.ikv.ATMtest. All rights reserved.
//

import Foundation
import Network
import UIKit

class UDPsend{
    

    var connection: NWConnection?
    var hostUDP: NWEndpoint.Host = ""
    var BGQUdpSend = DispatchQueue(label: "udp-con.bgsend.queue", attributes: [])
    var connectionArray = [NWConnection]()
    init(){
        print("UdpSendInit")
    }
    
    deinit{
        print("UdpSendDeInit")
    }
    func stop(){
        for connection in connectionArray {
                connection.cancel()
            }
        print("UdpSend stop")
    }



    func connectToUDP(_ hostUDP: NWEndpoint.Host, _ portUDP: 7890) {
        // Transmited message:
        let messageToUDP = "wuuuuu"

        self.connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)

        self.connection?.stateUpdateHandler = { [weak self](newState) in
            print("This is stateUpdateHandler:")
            switch (newState) {
            case .setup:
                print("Connection State: Setup")
                
                
            case .ready:
                print("Connection State: Ready")
                self.sendUDP(messageToUDP)
                self.connectionArray.append(self.connection)
                    
                self.receiveUDP()
            case .cancelled:
                print("Connection State: Cancelled")
            case .preparing:
                print("Connection State: Preparingn")
            default:
                print("ERROR! State not defined!")
            }
        }

        self.connection?.start(queue: self.BGQUdpSend)
    }
    func sendUDP(_ content: Data) {
        self.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: n (NWError!)")
            }
        })))
    }

    func receiveUDP(){
        self.connection?.receiveMessage { (data, context, isComplete, error) in
            if (isComplete) {
                print("Receive is complete")
                if (data != nil) {
                    let backToString = String(decoding: data!, as: UTF8.self)
                    print("Received message: \(backToString)")
                } else {
                    print("Data == nil")
                }
            }
        }
    }
}
