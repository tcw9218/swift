//import Photos
import UIKit
import AVFoundation

protocol ScanViewDelegate{
    func ScantoMain(qrstr : String?)
}


class scanController : UIViewController{
    
    var delegate : ScanViewDelegate?
    var avCaptureSession: AVCaptureSession!
    var avPreviewLayer: AVCaptureVideoPreviewLayer!

    //
    func failed() {
        let ac = UIAlertController(title: "Scanner not supported", message: "Please use a device with a camera. Because this device does not support scanning a code", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        avCaptureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (avCaptureSession?.isRunning == false) {
            avCaptureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (avCaptureSession?.isRunning == true) {
            avCaptureSession.stopRunning()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ( cameraAuthorize().authorize() ){
            
               avCaptureSession = AVCaptureSession()
               DispatchQueue.main.asyncAfter(deadline: .now() ) {
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
                   self.avPreviewLayer.frame = self.view.layer.bounds
                   self.avPreviewLayer.videoGravity = .resizeAspectFill
                   self.view.layer.addSublayer(self.avPreviewLayer)
                   self.avCaptureSession.startRunning()
               }
           }
    }
}


extension scanController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        avCaptureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            //myQrcode.text = stringValue
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            //
            delegate?.ScantoMain(qrstr: stringValue)
            navigationController?.popViewController(animated: true)
        }
        
        dismiss(animated: true)
    }

}

