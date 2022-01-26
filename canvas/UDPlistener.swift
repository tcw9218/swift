import Network
import Foundation
import UIKit
class listener {
    
   // let port: NWEndpoint.Port
    var stringToClient : String = ""
    var udpListener:NWListener?
    var backgroundQueueUdpListener   = DispatchQueue(label: "udp-lis.bg.queue", attributes: [])
    var backgroundQueueUdpConnection = DispatchQueue(label: "udp-con.bg.queue", attributes: [])
    init(){
        print("UDPinit")
    }
    
    deinit{
        print(" UDPdeinit")
    }
    
    func stop(){
        udpListener?.stateUpdateHandler = nil
        udpListener?.newConnectionHandler = nil
        udpListener?.cancel()
        print("UDP stop")
    }
    
    func start() {
        do {
            let params = NWParameters.udp
            params.allowLocalEndpointReuse = true
            self.udpListener = try NWListener(using: .udp, on: 7890)
            //self.udpListener = try NWListener(using: params, on: 7890)
            self.udpListener?.stateUpdateHandler = { (listenerState) in
                print(" NWListener Handler called")
                switch listenerState {
                case .setup:
                    print("Listener: Setup")
                case .waiting(let error):
                    print("Listener: Waiting \(error)")
                case .ready:
                    print("Listener: ✅ Ready and listens on port: \(self.udpListener?.port?.debugDescription ?? "-")")
                case .failed(let error):
                    print("Listener: Failed \(error)")
                    self.udpListener = nil
                case .cancelled:
                    print("Listener:  Cancelled by user")
//                    for connection in self.connections {
//                        connection.cancel()
//                    }
                    self.udpListener = nil
                default:
                    break;

                }
            }

            self.udpListener?.start(queue: backgroundQueueUdpListener)
            self.udpListener?.newConnectionHandler = { (incomingUdpConnection) in
                print(" NWConnection Handler called ")
                
                incomingUdpConnection.stateUpdateHandler = { (udpConnectionState) in
                    //print("Connection endpoint: \(incomingUdpConnection.endpoint)")
                    switch udpConnectionState {
                    case .setup:
                        print("Connection:  setup")
                    case .waiting(let error):
                        print("Connection:  waiting: \(error)")
                    case .ready:
                        print("Connection:  ready")
                       
                       // self.connections.append(incomingUdpConnection)
                        self.processData(incomingUdpConnection )
                        //print("fppfpsfsfs::\(self.stringToClient)")
                        //self.sendUDP(incomingUdpConnection , self.stringToClient)
                    case .failed(let error):
                        print("Connection:  failed: \(error)")
                        //self.connections.removeAll(where: {incomingUdpConnection === $0})
                    case .cancelled:
                        print("Connection:  cancelled")
                        //self.connections.removeAll(where: {incomingUdpConnection === $0})
                    default:
                        print("default")
                        break
                    }
                }
                incomingUdpConnection.start(queue: self.backgroundQueueUdpConnection)
            }
        } catch {
            print("CATCH")
        }
    }


    func processData(_ incomingUdpConnection :NWConnection ) {

        incomingUdpConnection.receiveMessage(completion: {[weak self](data, context, isComplete, error) in
            
            if let data = data, !data.isEmpty {
                print("data in = \(data)")
               //print("inUDP2gloasp: \(self!.gloasp!)")
                let  proUDP = processUdpData( data, incomingUdpConnection)
//                     let  proUDP = processUdpData(self!.gloasp, data, self!.ctapBtn ,self!.ctapBtn2 , incomingUdpConnection)
                    let dataout = proUDP.start()

                    incomingUdpConnection.send(content: dataout, completion:NWConnection.SendCompletion.contentProcessed(
                            ({(NWError) in
                                if (NWError == nil) {
                                  print("Data was sent to UDP ::\(dataout)")
                                }else {print("ERROR! Error when data sending. NWError: n (NWError!)")}
                               })))
                
            }
            print ("isComplete = \(isComplete)")
            if error == nil {
                self!.processData(incomingUdpConnection )
            }
        })
    }
}

