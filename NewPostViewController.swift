//
//  NewPostViewController.swift
//  Yarns
//
//  Created by Maduabuna Family on 2022-03-10.
//

import UIKit

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var txtcaption: UITextField!
    @IBOutlet weak var imgNewPost: UIImageView!
    let imagePicker = UIImagePickerController()
    var userid = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userid = UserDefaults.standard.string(forKey: "USERID")!
        
        txtcaption.borderStyle = UITextField.BorderStyle.roundedRect
        
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    //image button clicked to pick image
    @IBAction func imgNewPost_Clicked(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    //pick image implemented
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imgNewPost.contentMode = .scaleAspectFit
            imgNewPost.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnPost_Clicked(_ sender: Any) {
        
        let imgString = imgNewPost.image?.jpegData(compressionQuality: 100)?.base64EncodedString()
        let caption = txtcaption.text
        
        let date = Date()
//        let calendar =  Calendar.current
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let second = Calendar.current.component(.second, from: date)
        let millisecond = Calendar.current.component(.nanosecond, from: date)
        
        let medianame = "yarns_\(year)\(month)\(day)\(hour)\(minute)\(second)\(millisecond)"
        
        let mediatype = "image"
        
        if ((caption?.isEmpty)!)
        {
            displayMessage(msg: "Please enter a Caption")
            return
        }
        
//
        //create Activity Indicator
        let myActivityIndicator = UIActivityIndicatorView(style: .large)
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = true
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        //create Activity Indicator


        let myUrl = URL(string: "http://192.168.0.23/YarnsAPI/uploadImageiOS.php")
        var request = URLRequest(url:myUrl!)

        request.httpMethod = "POST"// Compose a quesry string
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let postString = ["image": imgString, "caption": caption, "medianame": medianame, "mediatype": mediatype, "userid": userid]

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
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "segueNewPostToHome", sender: nil)
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
    
    @IBAction func btnLogout_Click(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "ISUSERLOGGEDIN")
        performSegue(withIdentifier: "segueLogoutNewPostToHome", sender: nil)
    }
    
}
