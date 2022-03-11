//
//  ViewController.swift
//  Yarns
//
//  Created by Maduabuna Family on 2022-02-21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var txtusername: UITextField!
    @IBOutlet weak var txtpassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //set rounded corners for textfields
        txtusername.borderStyle = UITextField.BorderStyle.roundedRect
        txtpassword.borderStyle = UITextField.BorderStyle.roundedRect
        
//        addIconToLeft(txtField: txtusername, andImage: UIImage(named: "letterpng")!)
//        addIconToLeft(txtField: txtpassword, andImage: UIImage(named: "lockpng")!)
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.bool(forKey: "ISUSERLOGGEDIN") == true{
            //navidat to homestoryboard, HomeViewController is the code behind for HomeStroryBoard
            self.performSegue(withIdentifier: "segueLogintoHome", sender: nil)
        }
        
    }
    func addIconToLeft(txtField: UITextField, andImage img: UIImage){
        let leftIconImage = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: 10))
        leftIconImage.image = img
        txtField.leftView = leftIconImage
        txtField.leftViewMode = .always
    }
    @IBAction func btnLogin_Clicked(_ sender: Any) {
        let username_email = txtusername.text
        let password = txtpassword.text

        
        if ((username_email?.isEmpty)! || (password?.isEmpty)!)
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
        
        
        let myUrl = URL(string: "http://192.168.0.23/YarnsAPI/loginiOS.php")
        var request = URLRequest(url:myUrl!)
        
        request.httpMethod = "POST"// Compose a quesry string
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["username_email": username_email!, "password": password!] as [String: String]
        
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
                        
                        switch statuscode
                        {
                        case "200":
                            let userid = parseJSON["userid"] as? String
                            let emailaddress = parseJSON["email"] as? String
                            let username = parseJSON["username"] as? String
                            let fullname = parseJSON["fullname"] as? String
                            let profileimageurl = parseJSON["profileimageurl"] as? String
                            
                            //create sessions
                            UserDefaults.standard.set(true, forKey: "ISUSERLOGGEDIN")
                            UserDefaults.standard.set(userid, forKey: "USERID")
                            UserDefaults.standard.set(emailaddress, forKey: "EMAIL")
                            UserDefaults.standard.set(username, forKey: "USERNAME")
                            UserDefaults.standard.set(fullname, forKey: "FULLNAME")
                            UserDefaults.standard.set(profileimageurl, forKey: "PROFILEIMAGEURL")
                            
                            //navidat to homestoryboard, HomeViewController is the code behind for HomeStroryBoard
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "segueLogintoHome", sender: nil)
//
//                            let navigate = self.storyboard?.instantiateViewController(withIdentifier: "HomeStroryBoard") as! HomeViewController
//
//                            self.navigationController?.pushViewController(navigate, animated: true)
                            }
                            
                        case "201":
                            let emailaddress = parseJSON["email"] as? String
                            UserDefaults.standard.set(emailaddress, forKey: "EMAIL")
                            //navidat to confirmPageStoryBoard, ConfirmController is the code behind for confirmPageStoryBoard
                            let navigate = self.storyboard?.instantiateViewController(withIdentifier: "confirmPageStoryBoard") as! ConfirmController
                            self.navigationController?.pushViewController(navigate, animated: true)
                            
                        default:
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

