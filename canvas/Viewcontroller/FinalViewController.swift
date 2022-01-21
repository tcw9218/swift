//
//  FinalViewController.swift
//  canvas
//
//  Created by wu ted on 2022/1/19.
//

import UIKit

class FinalViewController: UIViewController {
    
    let Http = httpTaskClass()
    var server = ""
    let defaults = UserDefaults.standard
    var timer : Timer?
    var udplisten : listener?
    
    
    func toinform(){
        let VC_ingform = storyboard?.instantiateViewController(withIdentifier: "inform")as? informTableViewController
        //print(view.window)
        view.window?.rootViewController = VC_ingform
        view.window?.makeKeyAndVisible()
    }
    func toReigstered(){
        let VC_Registered = storyboard?.instantiateViewController(withIdentifier: "Registered")as? RegisteredController
        //print(view.window)
        view.window?.rootViewController = VC_Registered
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
    @IBAction  func selectbrn(){
        showbtn()
    }
    
    @IBAction func showDaemonid(_ sender: Any) {
        toinform()
    }
    @IBAction func Deregister(_ sender: Any) {
        Http.deregistered(server)
        //derigisterBtn.isHidden = true
        defaults.set("set_name", forKey: "state")
        timer?.invalidate()
        toReigstered()
    }
//
    let selfip = getip().getIpAddress()
    @IBOutlet weak var uuid : UILabel!
    @IBOutlet weak var usrname : UILabel!
    @IBOutlet weak var ctapBtn : UIButton!
    
    @IBAction func touchme(){
        print("touch me")
        let notify_userAround = Notification.Name("userIsAround")
        NotificationCenter.default.post(name: notify_userAround, object: nil)
        ctapBtn.isHidden = true
    }
//    MARK: TODO
    @IBOutlet weak var faceidbtn : UIButton!
    @IBAction func showfaceID(){
        print("faceid")
        let notify_FACEID = Notification.Name("FACEID")
        NotificationCenter.default.post(name: notify_FACEID, object: nil)
        faceidbtn.isHidden = true
    }
    
// 
    
    
 
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        udplisten?.udpListener?.cancel()
    }

    override func viewDidLoad() {
        //print("selfip:\(selfip)")
        //print("UUID:\(UUID.init())")
       
        super.viewDidLoad()
        ctapBtn.isHidden = true
        faceidbtn.isHidden = true
       // derigisterBtn.isHidden = false
        server =  defaults.string(forKey: "server") ?? ""
        let daemonid = defaults.string(forKey: "daemon_id")
       
        
//        MARK: first check http server is exist
        if(!Http.checkServer(server) ){
            print("server notexist")
        }else{
            if(daemonid != nil){
                Http.Querybinding( server)
                //Http.getAllItemInfo(daemonid!, server)
                timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                    self.Http.hearbeat(self.server, self.selfip!)
                        })
            }
        }
        
        let glo_asp = UnsafeMutablePointer<ASP_Data>.allocate(capacity : 1)
        ctap_handler_init(glo_asp)
        udplisten = listener( glo_asp , ctapBtn)
        udplisten!.start()
        
        let user = defaults.string(forKey: "displayname")
        if let user = user{
        usrname.text =   user
        }
        let uuidname = defaults.string(forKey: "UUID")
        if let uuid = uuid {
            uuid.text = uuidname
        }
        
       
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
