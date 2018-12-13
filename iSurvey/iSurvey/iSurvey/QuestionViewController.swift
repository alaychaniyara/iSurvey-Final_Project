//
//  QuestionViewController.swift
//  iSurvey
//
//  Created by Alay Chaniyara on 12/12/18.
//  Copyright © 2018 Alay Chaniyara. All rights reserved.
//

import UIKit
import Alamofire
class QuestionViewController: UIViewController {

    let getSurveyURL = URL(string: "http://18.234.165.21:3000/evaluators/displaySurvey")
    
    var questionList:Array<Any> = []
    var teamName = ""
    var teamCode = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = teamName
        getSurvey()
        // Do any additional setup after loading the view.
    }
    
    
   func getSurvey ()
   {
    Alamofire.request(self.getSurveyURL!, method: .get)
        .responseJSON { response in
            
            switch response.result {
            case .success:
                  print(response.result.value!)
                print("API CALLS SUCCESS")
                if let json = response.result.value {
                    let JSON = json as! NSDictionary
                    // print("JSON: \(JSON)")
                    let data = JSON["data"] as! NSArray;
                    let token = data[0] as! NSDictionary;
                    
                    for i in 1...8
                    {
                        
                        let question = token.object(forKey: "question\(i)") as! String
                        self.questionList.append(question)
                        
                    }
                    for i in 0...7
                    {
                        print(self.questionList[i])
                    }
                    // let teamlist = data[0] as! NSDictionary;
                  //  print(data.count)
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

}
