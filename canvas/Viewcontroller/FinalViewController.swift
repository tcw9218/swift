//
//  FinalViewController.swift
//  canvas
//
//  Created by wu ted on 2022/1/19.
//

import UIKit
import LocalAuthentication
import VideoToolbox

class FinalViewController: UIViewController {
    
    
    let glo_asp = UnsafeMutablePointer<ASP_Data>.allocate(capacity : 1)
    var Http : httpTaskClass? = httpTaskClass()
    var server = ""
    let defaults = UserDefaults.standard
    var timer : Timer?
    var udplisten : listener?
    var selfip = getip().getIpAddress()
    
//    @objc dynamic var FACEidresult = false
    
    var totalAccumulatedTime: TimeInterval = 0
    var lastDateObserved = Date()
    //let currentDate = Date()
    
    deinit{
        print("fnail deinit")
        NotificationCenter.default.removeObserver(self)
        
        if let ForeObserver =  ForeObserver{
        NotificationCenter.default.removeObserver(ForeObserver)
            }
    }
    
    func toinform(){
        let VC_inform = storyboard?.instantiateViewController(withIdentifier: "inform")as? informTableViewController
        //print(view.window)
        view.window?.rootViewController = VC_inform
        view.window?.makeKeyAndVisible()
    }
    
    func toReigstered(){
        let VC_Registered = storyboard?.instantiateViewController(withIdentifier: "Registered")as? RegisteredController
        //print(view.window)
        view.window?.rootViewController = VC_Registered
        view.window?.makeKeyAndVisible()
    }
    
    func toFirst(){
        let VC_First = storyboard?.instantiateViewController(withIdentifier: "First")as? ViewController
        //print(view.window)
        view.window?.rootViewController = VC_First
        view.window?.makeKeyAndVisible()
        
    }
//    MARK: dropdown
    
    @IBOutlet weak var morebtn: UIBarButtonItem!
    
    @IBAction func moreaction(_ sender: Any) {
        showbtn()
    }
    
    @IBOutlet var btnss: [UIButton]!
    func showbtn(){
        btnss.forEach{button in
            button.isHidden = !button.isHidden
            self.view.layoutIfNeeded()
        }
    }
    @IBAction  func selectbtn(){
        showbtn()
    }
    
    @IBAction func showDaemonid(_ sender: Any) {
        toinform()
    }
    
    @IBAction func bindMoreDaemon(_ sender: Any) {
        toReigstered()
    }
    
    @IBAction func Deregister(_ sender: Any) {
        let alert = UIAlertController(title: "Warning", message: "this will clear all information in your phone", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("Deregister")
            self.Http!.deregistered(self.server)
            //Http?.Querybinding(server) // ask daemoncount
            
                //derigisterBtn.isHidden = true
            self.defaults.set("installed", forKey: "state")
                
            self.timer?.invalidate()
            ATC_ADP_master_key_destroy()
            ATC_ADP_ecdsa256_attkey_destroy()
            authenticator_reset()
            self.glo_asp.deallocate()
            self.toFirst()
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          print("Handle Cancel deregister here")
          }))
        
        self.present(alert, animated: true, completion: nil)
    }

//    static var login  =  0
    @IBOutlet weak var uuid : UILabel!
    @IBOutlet weak var usrname : UILabel!
    @IBOutlet weak var ctapBtn : UIButton!
  
    

//    MARK: UPUV
    
    @objc func showcbor(notification: NSNotification){
        print(" showcbor received")
        //print(ctapBtn)
        DispatchQueue.main.async{
            self.ctapBtn.isHidden = false
            //print(self.ctapBtn)
        }
    }
    @IBAction func touchme(){
        print("touch me")
        let notify_userAround = Notification.Name("userIsAround")
        NotificationCenter.default.post(name: notify_userAround, object: nil)
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
      
            let reason = "User Verification"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
                if success {

                    print("success")
                    parameter.FACEidresult = true
                } else {
                    parameter.FACEidresult = false
//                    DispatchQueue.main.async { [unowned self] in
//                        self.showMessage(title: "Login Failed", message: error?.localizedDescription)
//                    }
                }
            }
        } else {
            //showMessage(title: "Failed", message: error?.localizedDescription)
        }
        ctapBtn.isHidden = !ctapBtn.isHidden
    }

//    MARK: observer
    private var ForeObserver: NSObjectProtocol?
   
    @objc func appMovedToBackground() {
        print("App moved to background!")
        udplisten?.stop()
        udplisten = nil
        
        
        totalAccumulatedTime = 0
        lastDateObserved = Date()
        //timer?.invalidate()
    }
    
    
//MARK: viewdidload
    override func viewDidLoad() {
        
         ForeObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
             print("App move to frontend")
             
             let currentDate = Date()
             let currentAccumulatedTime = currentDate.timeIntervalSince(lastDateObserved)
             totalAccumulatedTime +=  currentAccumulatedTime
             //lastDateObserved = currentDate
             print("currentAccumulatedTime::\(currentAccumulatedTime)")
             
             let context = LAContext()
             var error: NSError?
             if(totalAccumulatedTime >= 5){
                 if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
               
                     let reason = "User Verification"
                     context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
                         if success {
                             udplisten = listener()
                             udplisten!.start()
                         }
                     }
                 }
             }else{
                 udplisten = listener()
                 udplisten!.start()
                 
             }
                    // do whatever you want when the app is brought back to the foreground
                }
         NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        

        let cbor00 = Notification.Name("cbor00")
        NotificationCenter.default.addObserver(self, selector: #selector(showcbor(notification:)), name: cbor00, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(showcborUV(notification:)), name: UV, object: nil)
        
        super.viewDidLoad()
        ctapBtn.isHidden = true
        //ctapBtn2.isHidden = true

        server =  defaults.string(forKey: "server") ?? ""
        let daemonid = defaults.string(forKey: "daemon_id")
        print("token :::: \(parameter.fcmtoken)")
       
        
//        MARK: first check http server is exist
        if let Http = Http {
            Http.checkServer(server) { bool in
                if (bool){
                    if(daemonid != nil){
                        Http.Querybinding(self.server)
                        Http.hearbeat(self.server, self.selfip!)
                        
                        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self](_) in
                            //
                            if (self!.selfip != getip().getIpAddress() ){
                                self!.selfip = getip().getIpAddress() // renew ip address
                            }
                            
                            self?.Http?.hearbeat(self!.server, self!.selfip!)
                                })
                        let GLOASP = parameter.gloasp
                 
                        print("GLOASP: \(GLOASP)")
                        ctap_handler_init(GLOASP)
                        print("gloasp: \(GLOASP)")
                        self.udplisten = listener()
                        self.udplisten!.start()
                        
                        let user = self.defaults.string(forKey: "displayname")
                        if let user = user{
                            self.usrname.text =   user
                        }
                        let uuidname = self.defaults.string(forKey: "UUID")
                        if let uuid = self.uuid {
                            uuid.text = uuidname
                        }
                    }
                    
                }else{
                    
                    print("server notexist")
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        timer?.invalidate()
        udplisten?.stop()
        udplisten = nil
        Http = nil
        
        //Http.Querybinding( server)
    }
}



struct parameter {
    static var gloasp = UnsafeMutablePointer<ASP_Data>.allocate(capacity: 1)
    static var FACEidresult = false
    static var daemonCount = 0
    static var ServerdownIP = ""
    static var ServerdownPort = 0
    static var SelectDaemon = ""
    static var fcmtoken = ""
}
