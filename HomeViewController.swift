//
//  HomeViewController.swift
//  Yarns
//
//  Created by Maduabuna Family on 2022-03-09.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var vwBox: UIView!
    @IBOutlet var lblusername: UILabel!
    
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()


        lblusername.text = UserDefaults.standard.string(forKey: "USERNAME")
        
        vwBox.layer.borderWidth = 0.5
//        vwBox.layer.borderColor = UIColor.red.cgColor
        vwBox.layer.borderColor = UIColor(red: CGFloat(234)/255, green: CGFloat(105)/255, blue: CGFloat(67)/255, alpha: 1).cgColor
        vwBox.backgroundColor = UIColor.white
        
        // Do any additional setup after loading the view.
        
    }
    override func viewDidAppear(_ animated: Bool) {
//        lblusername.text = "\(username)"
    }
    @IBAction func btnLogout_Click(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "ISUSERLOGGEDIN")
        performSegue(withIdentifier: "segueLogoutToHome", sender: nil)
    }
    @IBAction func btnAddPost_Click(_ sender: Any) {
        performSegue(withIdentifier: "sequeHomeToNewPost", sender: nil)
    }
    
}
