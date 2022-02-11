//
//  SetNameController.swift
//  canvas
//
//  Created by wu ted on 2022/1/19.

import UIKit
import AVFoundation

class RegisteredController: UIViewController {
    
    var HttptoPost : httpTaskClass?
    let defaults = UserDefaults.standard
    var server = ""
    var daemon_id = ""
    
    var avCaptureSession: AVCaptureSession!
    var avPreviewLayer: AVCaptureVideoPreviewLayer!
    let camera_back = Notification.Name("camera_back")
    var camera_tag = false
    
    
    deinit{
        print("REgisterpage deinit")
    }
    @IBOutlet weak var squareview : UIImageView!
    @IBOutlet weak var label :UILabel!
    func failed() {
        let ac = UIAlertController(title: "Scanner not supported", message: "Please use a device with a camera. Because this device does not support scanning a code", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        avCaptureSession = nil
    }
    
    func toFinal(){
        let VC_Final = storyboard?.instantiateViewController(withIdentifier: "Final")as? FinalViewController
        //print(view.window)
        view.window?.rootViewController = VC_Final
        view.window?.makeKeyAndVisible()
    }
    
    @objc func checkTapbtn(notification: NSNotification){
        
        camera_tag = true
        HttptoPost = httpTaskClass()
        //print(label.text)
        let stringFromScan = label.text
        let IDstore = IDstorage()
        //go scan
        if let stringFromScan = stringFromScan {
            let scanArr = stringFromScan.components(separatedBy: "@")
            if(scanArr.count > 1){
                let daemon_id = scanArr[0]
                
                server = scanArr[1]
                
                defaults.set(server, forKey: "server")
                defaults.set(daemon_id, forKey: "daemon_id")
                IDstore.setDaemon(daemon_in : daemon_id)
                //print(server)
                //print(daemon_id)
                
                HttptoPost!.getAllItemInfo(daemon_id,server)
                toFinal()
            }else{
                label.text = "Wrong daemodid"
                goscan()
            }
            
            //defaults.set("registered", forKey: "state")
            //sleep(1)
           
        }
       

    }
    
    func goscan(){
        if ( true ){
             
             avCaptureSession = AVCaptureSession()
                guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                    self.failed()
                    return
                }
                let avVideoInput: AVCaptureDeviceInput

                do {
                    avVideoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                } catch {
                    self.failed()
                    return
                }

                if (self.avCaptureSession.canAddInput(avVideoInput)) {
                    self.avCaptureSession.addInput(avVideoInput)
                } else {
                    self.failed()
                    return
                }

                let metadataOutput = AVCaptureMetadataOutput()

                if (self.avCaptureSession.canAddOutput(metadataOutput)) {
                    self.avCaptureSession.addOutput(metadataOutput)

                    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr]
                } else {
                    self.failed()
                    return
                }

                self.avPreviewLayer = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)
                self.avPreviewLayer.frame = squareview.layer.frame
                self.avPreviewLayer.videoGravity = .resizeAspectFill
                self.view.layer.addSublayer(avPreviewLayer)
                self.squareview.layer.borderWidth = 7
                //self.squareview.layer.borderColor = UIColor.brown.cgColor
                //self.view.bringSubviewToFront(squareview)
                self.avCaptureSession.startRunning()
          
        }
       
        
    }
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkTapbtn(notification:)), name: camera_back, object: nil)
        
        super.viewDidLoad()

        print("registerePage")
        let _ = defaults.string(forKey: "state")
        goscan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        HttptoPost = nil
    }
}

extension RegisteredController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            label.text = stringValue
            print(stringValue)
            let camera_back = Notification.Name("camera_back")
            NotificationCenter.default.post(name: camera_back, object: nil)
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            navigationController?.popViewController(animated: true)
            
        }
        
        avCaptureSession.stopRunning()
        avPreviewLayer.removeFromSuperlayer()
        squareview.isHidden = true
        //dismiss(animated: true)
    }
}

//class RegisteredController: UIViewController {
//
//    @objc dynamic let HttptoPost = httpTaskClass()
//    let defaults = UserDefaults.standard
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("registerePage")
//        var state = defaults.string(forKey: "state")
//        if(state == "registered"){
//
//
//        }else{
//
//        }
//        // Do any additional setup after loading the view.
//    }
//
//
//
//}
