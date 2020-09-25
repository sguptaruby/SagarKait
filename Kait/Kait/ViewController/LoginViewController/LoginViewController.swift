//
//  LoginViewController.swift
//  Kait
//
//  Created by Apple on 25/03/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    var viewModal:LoginViewModal!
    
    /// view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        defaultInitialization()
    }
    
    func defaultInitialization() {
        //txtEmail.text = "test_user"//"test_user_new"//"test_user"
        //txtPassword.text = "test12345"
        txtEmail.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        txtPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        btnLogin.layer.cornerRadius = btnLogin.frame.height/2
        btnLogin.layer.masksToBounds = true
        viewModal = LoginViewModal()
        if Helpers.userToken() != "" && Helpers.getUserData().count != 0{
            let dict = Helpers.getUserData()
            AppManager.share.user = User(json: dict)
            Helpers.saveUserOnline(isOnline: AppManager.share.user.isActive)
            self.navigateToFriendList()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar()
    }
    
    /// textfield validation
    func vailidateData() -> Bool {
        if txtEmail.text?.count == 0 {
            self.showAlert(title: "Kait", message: "Please enter username .") {
                
            }
            return false
        }
        //        if (txtEmail.text?.isValidEmail())!{
        //            self.showAlert(title: "", message: "Please enter vaild email.") {
        //
        //            }
        //            return false
        //        }
        if txtPassword.text?.count == 0 {
            self.showAlert(title: "Kait", message: "Please enter password.") {
                
            }
            return false
        }
        return true
    }
    
    /// login button action
    /// - Parameter sender: button object
    @IBAction func btnLoginAction(sender:UIButton) {
        if vailidateData() {
            viewModal.email = txtEmail.text
            viewModal.password = txtPassword.text
            viewModal.device_token = Helpers.getDeviceToken()
            self.view.showHUD()
            viewModal.loginApi { (code, data, error) in
                self.view.hideHUD()
                if let dict = data {
                    print(dict)
                    AppManager.share.user = User(json: dict)
                    Helpers.saveUserToken(token: AppManager.share.user.userToken)
                    Helpers.saveUserData(data: dict)
                    Helpers.saveUserOnline(isOnline: AppManager.share.user.isActive)
                    self.navigateToFriendList()
                }else{
                    self.showAlert(title: "Kait", message: error?.desc ?? "Incorrect credentials") {
                        
                    }
                }
            }
        }
    }
    
    private func navigateToFriendList() {
        if #available(iOS 13.0, *) {
            let vc = self.storyboard?.instantiateViewController(identifier: "TabBarController") as! TabBarViewController
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            let vc: TabBarViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
    }
    
}


