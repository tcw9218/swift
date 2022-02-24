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
import LocalAuthentication

class ViewController: UIViewController {
    
//    let documentDirectoryUrl = try! FileManager.default.url(
//       for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
//    )
    var state = "installed"
    var timer : Timer?
    var server = ""
    var observation: NSKeyValueObservation?
    let defaults = UserDefaults.standard
   

//    MARK: SETNAME
    @IBOutlet weak var setnamebtn : UIButton!
    @IBOutlet weak var setnametext : UITextField!
    var displayname =  ""
    @IBAction func setnametapped(){
       
        displayname = setnametext.text!
        defaults.set(displayname, forKey: "displayname")
        defaults.set("set_name", forKey: "state")
        setnamebtn.isHidden = true
        setnametext.isHidden = true
        toReigstered()
    }
  
    
    func checkState(state : String){
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
    
    func toReigstered(){
        let VC_Registered = storyboard?.instantiateViewController(withIdentifier: "Registered")as? RegisteredController
        //print(view.window)
        view.window?.rootViewController = VC_Registered
        view.window?.makeKeyAndVisible()
    }
    
    func toFinal(){
        let VC_Final = storyboard?.instantiateViewController(withIdentifier: "Final")as? FinalViewController
        view.window?.rootViewController = VC_Final
        view.window?.makeKeyAndVisible()
    }


    override func viewDidLoad() {
        //print("File path \(documentDirectoryUrl.path)")
        let state_saved = defaults.string(forKey: "state")
        if(state_saved == nil ){
            print("just installed app")
        }else{
            print("not just installed app :: \(state_saved!)")
            state = state_saved!
        }
        if(state == "installed"){
            //let timestamp = NSDate().timeIntervalSince1970
            let UUID = UUID.init().uuidString
            defaults.set(UUID, forKey: "UUID")
            //print("renew UUID")
            state = "initialized"
            defaults.set("initialized", forKey: "state")
        }
        let inikey = iniKey()
        inikey.setall()
        checkState(state: state)
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {

            let reason = "User Verification"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
                if success {
                    DispatchQueue.main.async{
                        let state = self.defaults.string(forKey: "state")
                        if let state = state {
                            if(state == "set_name"){
                                //toFinal()
                                self.toReigstered()
                            }else if(state == "binded"){
                                self.toFinal()
                            }
                        }

                    }

                }
            }
        }
        print("view did appear")
//        let state = defaults.string(forKey: "state")
//        if let state = state {
//            if(state == "set_name"){
//                //toFinal()
//                toReigstered()
//            }else if(state == "binded"){
//                toFinal()
//            }
//        }
    }
    
    
    
    
    
    
//    MARK: segue
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
//        }
//    }
//}



