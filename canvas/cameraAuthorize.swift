//
//  cmeraAuthorize.swift
//  testcmera
//
//  Created by wu ted on 2021/12/9.
//
import AVFoundation
import Foundation
import UIKit
class cameraAuthorize: UIViewController{
    
    func authorize() -> Bool {
        
        let camStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch (camStatus){
        case (.authorized):
            return true
        case (.notDetermined):
            AVCaptureDevice.requestAccess(for: AVMediaType.video,  completionHandler: { (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorize()
                })
            })
        default:
            DispatchQueue.main.async(execute: {
                let alertController = UIAlertController(title: "提醒", message: "請點擊允許才可於APP內開啟相機", preferredStyle: .alert)
                let canceAlertion = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let settingAction = UIAlertAction(title: "設定", style: .default, handler: { (action) in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                print("跳至設定")
                            })
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                })
                alertController.addAction(canceAlertion)
                alertController.addAction(settingAction)
                self.present(alertController, animated: true, completion: nil)
            })
        }
        return false
    }
    
    
    
    
}
