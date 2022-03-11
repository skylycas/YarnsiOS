//
//  SignUpController.swift
//  Yarns
//
//  Created by Maduabuna Family on 2022-03-05.
//

import UIKit

class SignUpController: UIViewController {
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPhone: UITextField!
    @IBOutlet var txtfullname: UITextField!
    @IBOutlet var txtusername: UITextField!
    @IBOutlet var txtpassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doRoundTextBox()

        // Do any additional setup after loading the view.
    }
    
    func doRoundTextBox(){
        txtEmail.borderStyle = UITextField.BorderStyle.roundedRect
        txtPhone.borderStyle = UITextField.BorderStyle.roundedRect
        txtfullname.borderStyle = UITextField.BorderStyle.roundedRect
        txtusername.borderStyle = UITextField.BorderStyle.roundedRect
        txtpassword.borderStyle = UITextField.BorderStyle.roundedRect
    }
    
    @IBAction func lnkBacktoLogin_Click(_ sender: Any) {
        performSegue(withIdentifier: "gotoLoginFromSignup", sender: nil)
    }
    
    @IBAction func btnSignUp_Click(_ sender: Any) {
        let email = txtEmail.text
        let phone = txtPhone.text
        let fullname = txtfullname.text
        let username = txtusername.text
        let password = txtpassword.text
        
        if ((email?.isEmpty)! || (phone?.isEmpty)! || (fullname?.isEmpty)! || (username?.isEmpty)! || (password?.isEmpty)!)
        {
            displayMessage(msg: "One of the required field is missing")
            return
        }
        
        
        //create Activity Indicator
        let myActivityIndicator = UIActivityIndicatorView(style: .large)
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = true
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        //create Activity Indicator
        
        
        let myUrl = URL(string: "http://192.168.0.23/YarnsAPI/signupiOS.php")
        var request = URLRequest(url:myUrl!)
        
        request.httpMethod = "POST"// Compose a quesry string
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["email": email!, "phone": phone!, "fullname": fullname!, "username": username!, "password": password!] as [String: String]
        
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
                            UserDefaults.standard.set(self.txtEmail.text, forKey: "EMAIL")
                            
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "segueSignupConfirmation", sender: nil)
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
        let dataToBeSentToNextController = segue.destination as! ConfirmController
        DispatchQueue.main.async {
            dataToBeSentToNextController.email = self.txtEmail.text!
        }
    }
    
    
    @IBAction func lnkCanel_Click(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
