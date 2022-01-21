import UIKit
import Combine
class httpTaskClass: NSObject {
    override init(){
        print("http init")
    }
    deinit{
        print("https deinit")
    }
    
    
    var daemonid = ""
    //var daemon_arr : [String] = []
    var registered : Bool = false
    var isexist = true
    let defaults = UserDefaults.standard
    
    //@objc dynamic var binding_ID = ""
    
    
    
//    MARK: check if server alive
    func checkServer(_ server : String)->Bool{
        let session_status = URLSession(configuration:URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.current)
        let requestURL = URL(string: server)
        let urlRequest = URLRequest(url: requestURL!)
        
        
        let task = session_status.dataTask(with: urlRequest){(data, response, error) in
            if let data = data {
                print("server exist:\(data)")
            }
            else
            {
                self.isexist = false
                print("no server")
            }
        }
        task.resume()
        return isexist
    }
//MARK: - Deregister
    func deregistered(_ server :String){
        var dereg = dereg_Payload()
        dereg.ID = self.defaults.string(forKey: "UUID") ?? ""
        
        let session_status = URLSession(configuration:URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.current)
        let payloadJSONData = try! JSONEncoder().encode(dereg)
        let DeReg = payloadJSONData.urlSafeBase64EncodedString()
        
        createPost(session :session_status,qMes: genJWT().start(DeReg), url: server+"/register/deregister"){_,_ in
            print("derigstering")
            //self?.binding_ID = "Binding ID:"
        }
    }
    
//MARK: - Heartbeat
    func hearbeat(_ server :String , _ selfip : String){
        
        
        let session_status = URLSession(configuration:URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.current)
        var a = heartBeat_Payload()
        a.IP = selfip
        a.AID = self.defaults.string(forKey: "UUID") ?? ""
        let payloadJSONData = try! JSONEncoder().encode(a)
        let HearBeat = payloadJSONData.urlSafeBase64EncodedString()
        
        createPost(session :session_status,qMes: genJWT().start(HearBeat), url: server+"/report/sendReport"){ _,_ in
            print("heartbeat")
            //self?.binding_ID = "Binding ID:"
        }
    }
    func Querybinding(_ serverip : String){
        var query_reg = Query_Reg_Sta_Payload()
        query_reg.ID = self.defaults.string(forKey: "UUID") ?? ""
        let session_status = URLSession(configuration:URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.current)
        let payloadJSONData = try! JSONEncoder().encode(query_reg)
        let QueryBind = payloadJSONData.urlSafeBase64EncodedString()
        self.createPost(session :session_status,qMes:genJWT().start(QueryBind), url: serverip+"/binding/queryBindingA")
        { output, error in
            print("QuereyBindingStatus")
            print((String(data: output, encoding: String.Encoding.utf8) as String?)!)
          
            let jsonRes = try? JSONSerialization.jsonObject(with:output, options: [])as?[String:Any]
            let IDstore = IDstorage()
            
            if let jsonRes = jsonRes{
                for (dmonid, dataValue) in jsonRes {
                    print(dmonid)
                    IDstore.setDaemon(daemon_in: dmonid)
                   // print(self.daemon_arr.count)
                    //self.daemonid = dmonid
                    let dataValue = dataValue as? [String : String]
                    if let dataValue = dataValue {
                        print(dataValue["Display Name"] ?? "")
                        print(dataValue["ECDSApub"] ?? "")
                        print(dataValue["ECDHpub"] ?? "")
                    }
                }
            }
            else{
                print("jsonRes empty")
            }
        }
        
    }
    
    
    
//MARK: - from queryregister to binding
    func getAllItemInfo(_ daemonid : String,_ serverip : String) {
        

        
        let session_status = URLSession(configuration:URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.current)
        //print(registered)
        let group = DispatchGroup()
            group.enter()
//MARK: - QueryRegisterStauts
        var query_reg = Query_Reg_Sta_Payload()
        query_reg.ID = self.defaults.string(forKey: "UUID") ?? ""
        //print("query_reg.ID:\(query_reg.ID)")
        
        let payloadJSONData = try! JSONEncoder().encode(query_reg)
        
        
        let QueryReg = payloadJSONData.urlSafeBase64EncodedString()
        createPost(session :session_status,qMes: genJWT().start(QueryReg), url: serverip+"/register/queryStatus")//URL_Status().queryReg)
        { [weak self]output , error in
            let jsonRes = try? JSONSerialization.jsonObject(with:output, options: [])as?[String:String]
            //print(jsonRes)
            let result = jsonRes!
            if let result = result["RESULT"]{
                if result == "FALSE"{
                print("not registered")
                }else{// if true
                    print("tokenID has registered")
                    self!.registered = true
                    self!.defaults.set("registered", forKey: "state")
                }
            }
            group.leave()
        }
        
        group.notify(queue: .global())
        {
            if(self.registered){
//MARK: - querybindingStatus
//                var qrbind = Query_Bind_Stat_Payload()
//                qrbind.AID = self.defaults.string(forKey: "UUID") ?? ""
//
//                let payloadJSONData = try! JSONEncoder().encode(qrbind)
//                let QueryBind = payloadJSONData.urlSafeBase64EncodedString()
//                self.createPost(session :session_status,qMes:genJWT().start(QueryBind), url: serverip+"/binding/queryBindingA")
//                { output, error in
//                    print("QuereyBindingStatus")
//                    //print((String(data: output, encoding: String.Encoding.utf8) as String?)!)
//
//                    let jsonRes = try? JSONSerialization.jsonObject(with:output, options: [])as?[String:Any]
//                    if let jsonRes = jsonRes{
//                        for (dmonid, dataValue) in jsonRes {
//                            //self.daemon_arr.append(dmonid)
//                            print(self.daemon_arr.count)
//                            self.daemonid = dmonid
//                            let dataValue = dataValue as? [String : String]
//                            if let dataValue = dataValue {
//                                print(dataValue["Display Name"] ?? "")
//                                print(dataValue["ECDSApub"] ?? "")
//                                print(dataValue["ECDHpub"] ?? "")
//                            }
//                        }
//                    }
//                    else{
//                        print("jsonRes empty")
//                    }
//                }
            }else{
//MARK: - Register
                let displayname = self.defaults.string(forKey: "displayname") ?? ""
                var Reg_p = Reg_Payload()
                Reg_p.NOTE = displayname
                Reg_p.ID = self.defaults.string(forKey: "UUID") ?? ""
               
                let payloadJSONData = try! JSONEncoder().encode(Reg_p)
                let Reg = payloadJSONData.urlSafeBase64EncodedString()
                self.createPost(session :session_status,qMes: genJWT().start(Reg), url: serverip+"/register/register")
                {
                    output, error in
                    //let userDefault = UserDefaults()
                    print("now registering...")
                    print((String(data: output, encoding: String.Encoding.utf8) as String?)!)
                    self.defaults.set("registered", forKey: "state")
                    //userDefault.set( "true", forKey: "isRegistered")
                }
            }
//MARK: - Binding
            var Bp = Bind_Payload()
            Bp.DID = daemonid
            Bp.AID = self.defaults.string(forKey: "UUID") ?? ""
            let payloadJSONData = try! JSONEncoder().encode(Bp)
            let Bind = payloadJSONData.urlSafeBase64EncodedString()
            self.createPost(session :session_status,qMes: genJWT().start(Bind), url: serverip+"/binding/setBinding") { output , error in
                print("binding")
                print((String(data: output, encoding: String.Encoding.utf8) as String?)!)
                let jsonRes = try? JSONSerialization.jsonObject(with:output, options: [])as?[String:String]
                for (_, dataValue) in jsonRes! {
                    if(dataValue == "TRUE"){
                        self.defaults.set("binded", forKey: "state")
                        //self?.binding_ID = "Binding ID:  \(String(describing: self!.daemonid))"
                    }
                }
                //UserDefaults.standard.set("ec0ddef5-451f-4957-bd9b-793ad81a7d65", forKey: "Key")
            }
        }
    }

     func createPost(session : URLSession , qMes: String, url: String, completionBlock: @escaping (Data,Error?) -> Void)
       {
           let requestURL = URL(string: url)
           var urlRequest = URLRequest(url: requestURL!)

           urlRequest.httpMethod = "POST"
           var requestBodyComponents = URLComponents()
           requestBodyComponents.queryItems = [URLQueryItem(name: "JWT", value: qMes )]
           urlRequest.httpBody = requestBodyComponents.query?.data(using: .utf8)
           
           let requestTask = session.dataTask(with: urlRequest)
           {
               
               (data: Data?, response: URLResponse?, error: Error?) in
               if let data = data {
                   completionBlock(data,error);
               }else{
                   print("data empty")
               }
           }
           requestTask.resume()
       }
}
//MARK: - urldelegate
extension httpTaskClass: URLSessionDelegate{
    //for http use
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if challenge.protectionSpace.serverTrust == nil {
            //print("servertrusrt=nil")
            completionHandler(.useCredential, nil)
        }else{
            let trust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            //print("credential set to trust")
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
        }
    }
}

