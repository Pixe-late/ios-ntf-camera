//
//  LoginViewController.swift
//  Pixelate
//
//  Created by Taneja-Mac on 09/08/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var logoBGView: UIView!
    @IBOutlet weak var usernameBGView: UIView!
    @IBOutlet weak var passwordBGView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initializeView() {
        self.formatSubViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.usernameTextfield.resignFirstResponder()
        self.passwordTextfield.resignFirstResponder()
    }
    
    fileprivate func formatSubViews() {
        self.loginLabel.borderMe()
        self.loginLabel.borderColor(color: .black)
        self.passwordLabel.borderMe()
        self.passwordLabel.borderColor(color: .black)
        self.usernameLabel.borderMe()
        self.usernameLabel.borderColor(color: .black)
        self.logoBGView.borderMe(thickness: 2.0)
        self.logoBGView.borderColor(color: .black)
        self.usernameBGView.borderMe()
        self.usernameBGView.borderColor(color: .black)
        self.passwordBGView.borderMe()
        self.passwordBGView.borderColor(color: .black)
        self.registerButton.borderMe()
        self.registerButton.borderColor(color: .black)
        self.enterButton.borderMe()
        self.enterButton.borderColor(color: .black)
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
        let username = self.usernameTextfield.text ?? ""
        let password = self.passwordTextfield.text ?? ""
        username != "" ? password != "" ? ModelFactory.login(username: username, password: password).get(id: nil, params: [:], callback: { (error:NSError?, result:Any?) in
            let resultObj = result as? AnyPayload
            let message: String = resultObj?.dictionary["message"] as? String ?? "Invalid Cridentials."
            message != "Authentication Successful!" ? Alert.shared.show(self, alert: message) : self.setLogin()
        }) : Alert.shared.show(self, alert: "Please enter password.") : Alert.shared.show(self, alert: "Please enter email.")
//        self.usernameTextfield.text == "master" && self.passwordTextfield.text == "master" ? self.performSegue(withIdentifier: "LoginToCameraSegue", sender: self) : Alert.shared.show(self, alert: "Invalid Username Password")
    }
    
    fileprivate func setLogin() {
        MyDevice.setUserLoggedIn()
        self.performSegue(withIdentifier: "LoginToCameraSegue", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
