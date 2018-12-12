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

    let baseURL = URL(string: "http://172.20.4.178:3000/evaluators/authenticateUser")
    
    var evaluatorName = ""
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
        /*
         // Get the back-facing camera for capturing videos
         let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
         
         guard let captureDevice = deviceDiscoverySession.devices.first else {
         print("Failed to get the camera device")
         return
         }
         
         do {
         // Get an instance of the AVCaptureDeviceInput class using the previous device object.
         let input = try AVCaptureDeviceInput(device: captureDevice)
         
         // Set the input device on the capture session.
         captureSession?.addInput(input)
         
         let captureMetadataOutput = AVCaptureMetadataOutput()
         captureSession?.addOutput(captureMetadataOutput)
         // Set delegate and use the default dispatch queue to execute the call back
         captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
         captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
         
         // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
         videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
         videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
         videoPreviewLayer?.frame = view.layer.bounds
         view.layer.addSublayer(videoPreviewLayer!)
         
         
         // Start video capture.
         captureSession!.startRunning()
         
         } catch {
         // If any error occurs, simply print it out and don't continue any more.
         print(error)
         return*/
        
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "loggedIn"
//        {
//            let vc = segue.destination as! HomeViewController
//            vc.evaluatorNameId = evaluatorName
//        }
//    }
    func found(code: String) {
    
        print(code)
        
        let parameters:Parameters = ["scannedCode": code]
        Alamofire.request(self.baseURL!, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                      print(response.result.value)
                    print("API CALLS SUCCESS")
//  print(response.result.value)
//                    if let json = response.result.value {
//                        let JSON = json as! NSDictionary
//                        // print("JSON: \(JSON)")
//                        let data = JSON["data"] as! NSDictionary;
//                        let token = data["token"] as! String;
//                        self.saveToken(token: token)
//                        UserDefaults.standard.set(false, forKey: "status")
//                        print("Validation Successful")
//                        self.performSegue(withIdentifier: "showTeams", sender: self)
//                    }
                case .failure(_):
                    print("some error occured")
                }
        }
        //evaluatorName = code
        //performSegue(withIdentifier: "loggedIn", sender: self)  }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}

