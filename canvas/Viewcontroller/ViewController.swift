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
    
    let documentDirectoryUrl = try! FileManager.default.url(
       for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
    )
    var state = "installed"

//    MARK: SETNAME
    @IBOutlet weak var setnamebtn : UIButton!
    @IBOutlet weak var setnametext : UITextField!
    var displayname =  ""
    @IBAction func setnametapped(){
       
        displayname = setnametext.text!
        defaults.set(displayname, forKey: "displayname")
        defaults.set("set_name", forKey: "state")
        setnamebtn.alpha = 0
        setnametext.alpha = 0
        toReigstered()
    }
    func toReigstered(){
        let VC_Registered = storyboard?.instantiateViewController(withIdentifier: "Registered")as? RegisteredController
        //print(view.window)
        view.window?.rootViewController = VC_Registered
        view.window?.makeKeyAndVisible()
    }
    
    func displayName(state : String){
         let state = defaults.string(forKey: "state")
//        state = "initialized"
//        defaults.set("initialized", forKey: "state")
        if let state = state {
            if(state == "initialized"){
                setnamebtn.isHidden = false
                setnametext.isHidden = false
                
            }else{
                setnamebtn.isHidden = true
                setnametext.isHidden = true
                }
            }
        }
    
    func toFinal(){
        let VC_Final = storyboard?.instantiateViewController(withIdentifier: "Final")as? FinalViewController
        view.window?.rootViewController = VC_Final
        view.window?.makeKeyAndVisible()
    }
    
    

    
    var timer : Timer?
    var server = ""
    var observation: NSKeyValueObservation?
    let defaults = UserDefaults.standard
    //@objc dynamic let HttptoPost = httpTaskClass()
    let selfip = getip().getIpAddress()

    


    override func viewDidLoad() {
        //print("File path \(documentDirectoryUrl.path)")
        let state_saved = defaults.string(forKey: "state")
        if(state_saved == nil ){
            print("first login")
        }else{
            print("not first login :: \(state_saved!)")
            state = state_saved!
            
        }
        if(state == "installed"){
            let timestamp = NSDate().timeIntervalSince1970
            let UUID = UUID.init().uuidString
            defaults.set(UUID, forKey: "UUID")
            print("renew UUID")
            
            state = "initialized"
            defaults.set("initialized", forKey: "state")
//            if(cameraAuthorize().authorize() ){
//                print("camera ok")
//            }
           
        }
        
        let inikey = iniKey()
        inikey.setall()

        displayName(state: state)
        print(state)
       
        
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let state = defaults.string(forKey: "state")
        if let state = state {
            if(state == "set_name"){
                //toFinal()
                toReigstered()
            }else if(state == "binded"){
                toFinal()
            }
        }
    }
    

////    MARK: segue
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if(segue.identifier == "goScanSegue"){
//            guard let scan = segue.destination as? scanController else {return}
//            scan.delegate = self
//        }
//    }
}
//MARK: - scanDelegate
//extension ViewController:ScanViewDelegate{
//
//    func ScantoMain(qrstr: String?) {
//        if let  stringFromScan = qrstr {
//            let idstore = IDstorage()
//            //self.myScanField.text = stringFromScan
//            //print(stringFromScan)
//            let scanArr = stringFromScan.components(separatedBy: "@")
//            let daemon_id = scanArr[0]
//            server = scanArr[1]
//            print(daemon_id)
//            defaults.set(server, forKey: "server")
//            defaults.set(daemon_id, forKey: "daemon_id")
//            HttptoPost.getAllItemInfo(daemon_id,server)
//            HttptoPost.hearbeat(server, selfip!)
//            idstore.setDaemon(daemon_in: daemon_id, server_in: server)
//            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
//                ViewController().HttptoPost.hearbeat(self.server, self.selfip!)
//
//                    })
//
//        }
//    }
//}



