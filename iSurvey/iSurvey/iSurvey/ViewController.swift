//
//  ViewController.swift
//  iSurvey
//
//  Created by Alay Chaniyara on 12/4/18.
//  Copyright © 2018 Alay Chaniyara. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    let baseURL = URL(string: "http://18.234.165.21:3000/evaluators/authenticateUser")
    
    var evaluatorName = ""
    var evaluatorCode = ""
    
    //variable declaration for QR CODE
    var captureSession:AVCaptureSession!
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    var qrCodeFrameView:UIView?
    
    @IBOutlet weak var Login: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        Login.backgroundColor = UIColor.darkGray
        
        Login.layer.cornerRadius = Login.frame.height / 2
        Login.setTitleColor(UIColor.white, for: .normal)
        Login.layer.shadowColor = UIColor.red.cgColor
        Login.layer.shadowRadius = 25
        Login.layer.shadowOpacity = 1
        Login.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func scanQR(_ sender: Any) {
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = view.layer.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
       
        
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loggedIn"       {
            let vc = segue.destination as! HomeViewController
            vc.evaluatorNameId = evaluatorName
            vc.evaluatorCode = evaluatorCode
        }
    }
    func found(code: String) {
    
        print(code)
        
        let parameters:Parameters = ["scannedCode": code]
        Alamofire.request(self.baseURL!, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                      print(response.result.value!)
                    print("API CALLS SUCCESS")
                     if let json = response.result.value {
                        let JSON = json as! NSDictionary
                        // print("JSON: \(JSON)")
                        let data = JSON["result"] as! NSArray;
                        let token = data[0] as! NSDictionary;
                       // self.saveToken(token: token)
                        UserDefaults.standard.set(false, forKey: "status")
                        print("Validation Successful")
                        self.evaluatorName = token.object(forKey: "evaluatorName") as! String
                       self.evaluatorCode = token.object(forKey: "qrCode") as! String
                        self.performSegue(withIdentifier: "loggedIn", sender: self)
                     }
                case .failure(_):
                    print("some error occured")
                }
        }
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    
}

