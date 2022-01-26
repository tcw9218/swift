//
//  FinalViewController.swift
//  canvas
//
//  Created by wu ted on 2022/1/19.
//

import UIKit
import LocalAuthentication

class FinalViewController: UIViewController {
    
    
    let glo_asp = UnsafeMutablePointer<ASP_Data>.allocate(capacity : 1)
    var Http : httpTaskClass? = httpTaskClass()
    var server = ""
    let defaults = UserDefaults.standard
    var timer : Timer?
    var udplisten : listener?
    
//    @objc dynamic var FACEidresult = false
    
    deinit{
        print("fnail deinit")
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
    
    
    @IBAction func Deregister(_ sender: Any) {
        Http!.deregistered(server)
        //derigisterBtn.isHidden = true
        defaults.set("installed", forKey: "state")
        
        timer?.invalidate()
        ATC_ADP_master_key_destroy()
        ATC_ADP_ecdsa256_attkey_destroy()
        authenticator_reset()
        glo_asp.deallocate()
        toFirst()
    }
//
    let selfip = getip().getIpAddress()
    static var login  =  0
    @IBOutlet weak var uuid : UILabel!
    @IBOutlet weak var usrname : UILabel!
    @IBOutlet weak var ctapBtn : UIButton!
    @IBOutlet weak var ctapBtn2 : UIButton!
    

    

    

 
    
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
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      
            let reason = "User Verification"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                if success {
//                    DispatchQueue.main.async { [unowned self] in
//                        self.showMessage(title: "Login Successful", message: nil)
//                    }
                    print("success")
                    GLOASP.FACEidresult = true
                } else {
                    GLOASP.FACEidresult = false
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
   
    @objc func showcborUV(notification: NSNotification){
        print(" showcborUV received")
        //print(ctapBtn)
        DispatchQueue.main.async{
            self.ctapBtn2.isHidden = false
            //print(self.ctapBtn)
        }
        
    }
    @IBAction func touchme2(){
        print("touch me2 UV")
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      
            let reason = "User Verification"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                if success {
//                    DispatchQueue.main.async { [unowned self] in
//                        self.showMessage(title: "Login Successful", message: nil)
//                    }
                    print("success")
                    GLOASP.FACEidresult = true
                } else {
                    GLOASP.FACEidresult = false
//                    DispatchQueue.main.async { [unowned self] in
//                        self.showMessage(title: "Login Failed", message: error?.localizedDescription)
//                    }
                }
            }
        } else {
            //showMessage(title: "Failed", message: error?.localizedDescription)
        }
       
        ctapBtn2.isHidden = !ctapBtn2.isHidden
    }
    
//MARK: viewdidload
    override func viewDidLoad() {
        let GLOASP = GLOASP.gloasp
        
        //print("selfip:\(selfip)")
        //print("UUID:\(UUID.init())")
        print("GLOASP: \(GLOASP)")
        let cbor00 = Notification.Name("cbor00")
        let UV = Notification.Name("cbor00uv")
        NotificationCenter.default.addObserver(self, selector: #selector(showcbor(notification:)), name: cbor00, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showcborUV(notification:)), name: UV, object: nil)
        
        super.viewDidLoad()
        ctapBtn.isHidden = true
        ctapBtn2.isHidden = true

        server =  defaults.string(forKey: "server") ?? ""
        let daemonid = defaults.string(forKey: "daemon_id")
       
        
//        MARK: first check http server is exist
        if let Http = Http {
            if(!Http.checkServer(server) ){
                print("server notexist")
            }else{
                if(daemonid != nil){
                    //Http.Querybinding( server)
                    //Http.getAllItemInfo(daemonid!, server)
                    timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self](timer) in
                        self?.Http?.hearbeat(self!.server, self!.selfip!)
                            })
                }
            }
        }
        
  //      let glo_asp = UnsafeMutablePointer<ASP_Data>.allocate(capacity : 1)
        ctap_handler_init(GLOASP)
        print("gloasp: \(GLOASP)")
        udplisten = listener(  )
        udplisten!.start()
        
        let user = defaults.string(forKey: "displayname")
        if let user = user{
        usrname.text =   user
        }
        let uuidname = defaults.string(forKey: "UUID")
        if let uuid = uuid {
            uuid.text = uuidname
        }
    }

 
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        timer?.invalidate()
//        udplisten?.stop()
//        udplisten = nil
        Http = nil
        //Http.Querybinding( server)
    }
}




struct GLOASP {
    static var gloasp = UnsafeMutablePointer<ASP_Data>.allocate(capacity: 1)
    static var FACEidresult = false
}
