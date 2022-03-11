//
//  ConfirmController.swift
//  Yarns
//
//  Created by Maduabuna Family on 2022-03-05.
//

import UIKit

class ConfirmController: UIViewController {
    @IBOutlet var lblemail: UILabel!
    @IBOutlet var txtConfirmationCode: UITextField!
    
    var email = ""
    var username = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtConfirmationCode.borderStyle = UITextField.BorderStyle.roundedRect
        // Do any additional setup after loading the view.
        lblemail.text = UserDefaults.standard.string(forKey: "EMAIL")
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        lblemail.text = "\(email)"
    }
    
    
    @IBAction func lnkBacktoLogin_Click(_ sender: Any) {
        performSegue(withIdentifier: "gotoLoginFromConfirmation", sender: nil)
    }
    
    
    
    @IBAction func btnConfirmToken_Click(_ sender: Any) {
        let emailadd = lblemail.text!
        let confirmCode = txtConfirmationCode.text!
        
        if ((confirmCode.isEmpty))
        {
            displayMessage(msg: "Type in Confirmation Code")
            return
        }
        
        
        //create Activity Indicator
        let myActivityIndicator = UIActivityIndicatorView(style: .large)
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = true
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        //create Activity Indicator
        
        
        let myUrl = URL(string: "http://192.168.0.23/YarnsAPI/confirmtokeniOS.php")
        var request = URLRequest(url:myUrl!)
        
        request.httpMethod = "POST"// Compose a quesry string
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["email": emailadd, "token": confirmCode] as [String: String]
        
        do
        {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        }
        catch let error
        {
            print(error.localizedDescription)
            return
        }

        
        let task = URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            //remove activity indicator since we are done connecting to the server
            self.removeActivity(activityIndicator: myActivityIndicator)
            
            if (error != nil)
            {
                print("erroooooorrrrrr=\(String(describing: error))")
                return
            }
            else
            {
                do
                {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    
                    if let parseJSON = json{
                        let statuscode = parseJSON["statuscode"] as? String
                        let statusmessage = parseJSON["message"] as? String
                        
                        if (statuscode == "200")
                        {
                            self.username = (parseJSON["username"] as? String)!
                            
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "segueFromConfirmToHome", sender: nil)
                            }

                        }
                        else
                        {
                            print("statuscode = \(String(describing: statuscode)) and message = ")
                            
                            self.displayMessage(msg: "\(statusmessage!)")
                            
                            return
                        }
                    }
                    else
                    {
                        print("could not perfom the operation")
                        
                        self.displayMessage(msg: "could not perfom the operation")
                        return
                    }
                }
                catch
                {
                    print("erroooooorrrrrr222=\(String(describing: error))")
                }
            }
        }
        task.resume()
    }
    
    //use this to send data to the next page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dataToBeSentToNextController = segue.destination as! HomeViewController
        DispatchQueue.main.async {
            dataToBeSentToNextController.username = self.username
        }
    }
    
    func displayMessage(msg:String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
//            {
//                (action:UIAlertAction!) in
//                DispatchQueue.main.async {
//                    self.dismiss(animated: true, completion: nil)
//                }
//            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func removeActivity(activityIndicator: UIActivityIndicatorView){
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
}
