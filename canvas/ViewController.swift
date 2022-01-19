//
//  ViewController.swift
//  canvas
//
//  Created by wu ted on 2021/12/3.
//
import UIKit
import Network
import Foundation
import CoreData

class ViewController: UIViewController {
    
    
//    {
//        didSet{print("newserver\(server)")
//        }
//    }
    
//    let documentDirectoryUrl = try! FileManager.default.url(
//       for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
//    )
    
    var timer : Timer?
    var server = ""
    var observation: NSKeyValueObservation?
    let defaults = UserDefaults.standard
    @objc dynamic let HttptoPost = httpTaskClass()
    let selfip = getip().getIpAddress()

    
    @IBAction func touchme(){
        let notify_userAround = Notification.Name("userIsAround")
        NotificationCenter.default.post(name: notify_userAround, object: nil)
        ctapBtn.isHidden = true
    }

//
    
    @IBOutlet weak var ctapBtn : UIButton!
   // @IBOutlet weak var myScanField : UITextField!
 //   @IBOutlet weak var binding_deamon : UITextField!
 
    @IBAction func deRegistered(){
        HttptoPost.deregistered(server)
        
    }
//    MARK: viewdidload
    override func viewDidLoad() {
        
      
        ctapBtn.isHidden = true
        
        server =  defaults.string(forKey: "server") ?? ""
        let daemonid = defaults.string(forKey: "daemon_id")
//        MARK: first check http server is exist
        if(!HttptoPost.checkServer(server) ){
            print("server notexist")
            
            
        }else{
            if(daemonid != nil){
                HttptoPost.getAllItemInfo(daemonid!,server)
                
                timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                    self.HttptoPost.hearbeat(self.server, self.selfip!)
                        })
            }
           
            let glo_asp = UnsafeMutablePointer<ASP_Data>.allocate(capacity : 1)
            
            
            let inikey = iniKey(glo_asp)
            inikey.setall()
            ctap_handler_init(glo_asp)

            super.viewDidLoad()
            let udplisten = listener( glo_asp , ctapBtn)
            udplisten.start()
            
        }
        //print(server)
        //print(daemonid)
       
 
//        print("File path \(documentDirectoryUrl.path)")
//        print(UUID().uuidString)
        
//        observation = observe(\.HttptoPost.binding_ID, options:[.old, .new])
//        { (object, change) in
//                  self.binding_deamon.text = change.newValue
//        }

    }
//    MARK: segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goScanSegue"){
            guard let scan = segue.destination as? scanController else {return}
            scan.delegate = self
        }
    }
}
//MARK: - scanDelegate
extension ViewController:ScanViewDelegate{

    func ScantoMain(qrstr: String?) {
        if let  stringFromScan = qrstr {
            let idstore = IDstorage()
            //self.myScanField.text = stringFromScan
            //print(stringFromScan)
            let scanArr = stringFromScan.components(separatedBy: "@")
            let daemon_id = scanArr[0]
            server = scanArr[1]
            print(daemon_id)
            defaults.set(server, forKey: "server")
            defaults.set(daemon_id, forKey: "daemon_id")
            HttptoPost.getAllItemInfo(daemon_id,server)
            HttptoPost.hearbeat(server, selfip!)
            idstore.setDaemon(daemon_in: daemon_id, server_in: server)
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                ViewController().HttptoPost.hearbeat(self.server, self.selfip!)
                      
                    })
            
        }
    }
}



