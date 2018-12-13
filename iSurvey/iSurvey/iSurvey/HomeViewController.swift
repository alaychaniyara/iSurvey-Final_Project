//
//  HomeViewController.swift
//  iSurvey
//
//  Created by Alay Chaniyara on 12/4/18.
//  Copyright © 2018 Alay Chaniyara. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

class HomeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, AVCaptureMetadataOutputObjectsDelegate {
  
    @IBOutlet weak var buttonTeamSelect: UIButton!
    
    var teamName = ""
    var teamCode = ""
    
    var captureSession:AVCaptureSession!
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    var qrCodeFrameView:UIView?
    
    
    @IBAction func scanTeam(_ sender: Any) {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teamList.count
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell", for: indexPath)
        let teamName = cell.viewWithTag(10) as! UILabel
        teamName.text = (self.teamList[indexPath.row] as! String)
        return cell
    }
    
    let getTeamURL = URL(string: "http://18.234.165.21:3000/evaluators/teamsList")
    let scanTeamURL = URL(string: "http://18.234.165.21:3000/evaluators/authenticateTeam")
    
    var teamList:Array<Any> = []
    @IBOutlet weak var selectTeam: UIButton!
    @IBOutlet weak var evaluatorName: UILabel!
    var evaluatorNameId = ""
    @IBOutlet weak var teamTable: UITableView!
    var evaluatorCode = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonTeamSelect.backgroundColor = UIColor.darkGray
        
        buttonTeamSelect.layer.cornerRadius = buttonTeamSelect.frame.height / 2
        buttonTeamSelect.setTitleColor(UIColor.white, for: .normal)
        buttonTeamSelect.layer.shadowColor = UIColor.green.cgColor
        buttonTeamSelect.layer.shadowRadius = 25
        buttonTeamSelect.layer.shadowOpacity = 1
        buttonTeamSelect.layer.shadowOffset = CGSize(width: 0, height: 0)
       getteamsList()
        teamTable.isHidden = true
        self.title = evaluatorNameId
        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectTeamAction(_ sender: Any) {
       //
        if self.teamTable.isHidden{
            animate(toogle: true)
        }
        }

    func animate (toogle: Bool)
    {
        if toogle
        {UIView.animate(withDuration: 0.3)
            { self.teamTable.isHidden = false
            }
        }
        else
        {UIView.animate(withDuration: 0.3)
            {self.teamTable.isHidden = true
            }
        }
    }
    
    func getteamsList(){
       // let parameters:Parameters = ["scannedCode": code]
        Alamofire.request(self.getTeamURL!, method: .get)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                  //  print(response.result.value!)
                    print("API CALLS SUCCESS")
                    if let json = response.result.value {
                        let JSON = json as! NSDictionary
                        // print("JSON: \(JSON)")
                        let data = JSON["data"] as! NSArray;
                        for i in 0...data.count-1
                        {
                            let team = data[i] as! NSDictionary
                            self.teamList.append(team.object(forKey: "teamName"))
                            print(self.teamList[i])
                        }
                       // let teamlist = data[0] as! NSDictionary;
                       print(data.count)
                        // self.saveToken(token: token)
                        UserDefaults.standard.set(false, forKey: "status")
                        print("Validation Successful")
                        //self.evaluatorName = token.object(forKey: "evaluatorName") as! String
                        //self.evaluatorCode = token.object(forKey: "qrCode") as! String
                        //self.performSegue(withIdentifier: "loggedIn", sender: self)
                    }
                case .failure(_):
                    print("some error occured")
                }
        }
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
        if segue.identifier == "showQuestions"       {
            let vc = segue.destination as! QuestionViewController
            vc.teamCode = teamCode
            vc.teamName = teamName
        }
    }
    
    func found(code: String) {
        
        print(code)
        
        let parameters:Parameters = ["scannedCode": code]
        Alamofire.request(self.scanTeamURL!, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    print(response.result.value!)
                    print("API CALLS SUCCESS for team")
                    if let json = response.result.value {
                    let JSON = json as! NSDictionary
                    // print("JSON: \(JSON)")
                    let data = JSON["result"] as! NSArray;
                    let token = data[0] as! NSDictionary;
                    // self.saveToken(token: token)
                    UserDefaults.standard.set(false, forKey: "status")
                    print("Validation Successful")
                    self.teamName = token.object(forKey: "teamName") as! String
                    self.teamCode = token.object(forKey: "qrCode") as! String
                    self.performSegue(withIdentifier: "showQuestions", sender: self)
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


