//
//  LoginViewController.swift
//  SnipIt
//
//  Created by Hunter Meyer on 3/11/15.
//  Copyright (c) 2015 Hunter Meyer. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signinView: UIView!
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var signinEmail: UITextField!
    @IBOutlet weak var signinPassword: UITextField!
    @IBOutlet weak var signinSubmit: UIButton!
    @IBOutlet weak var signupToggle: UIButton!
    @IBOutlet weak var signupFirstName: UITextField!
    @IBOutlet weak var signupLastName: UITextField!
    @IBOutlet weak var signupEmail: UITextField!
    @IBOutlet weak var signupPassword: UITextField!
    @IBOutlet weak var signupSubmit: UIButton!
    @IBOutlet weak var signinToggle: UIButton!
    
    let httpHelper = HTTPHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlertMessage(alertTitle:NSString, alertDescription:NSString) -> Void {
        activityIndicator.fadeOut(duration: 0.0)
        let errorAlert: UIAlertController = UIAlertController(title: alertTitle as String, message: alertDescription as String, preferredStyle: .Alert)
        let cancelAlert: UIAlertAction = UIAlertAction(title: "Got it", style: .Cancel) { action -> Void in }
        errorAlert.addAction(cancelAlert)
        
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }
    
    @IBAction func signInSubmit(sender: UIButton) {
        activityIndicator.fadeIn(duration: 0.0)
        if signinEmail.text.isEmpty || signinPassword.text.isEmpty {
            displayAlertMessage("All fields required", alertDescription: "Some fields are missing input")
        }else {
            makeSignInRequest(signinEmail.text, userPassword: signinPassword.text)
        }
    }
    
    @IBAction func signupSubmit(sender: UIButton) {
        activityIndicator.fadeIn(duration: 0.0)
        if signupFirstName.text.isEmpty || signupLastName.text.isEmpty || signupEmail.text.isEmpty || signupPassword.text.isEmpty {
            displayAlertMessage("All fields required", alertDescription: "Some fields are missing input")
        }else {
            makeSignUpRequest(signupFirstName.text, lastName: signupLastName.text, userEmail: signupEmail.text, userPassword: signupPassword.text)
        }
    }
    
    func makeSignUpRequest(firstName: String, lastName: String, userEmail: String, userPassword: String) {
        let httpRequest = httpHelper.buildRequest("signup", method: "POST", authType: HTTPRequestAuthType.HTTPBasicAuth)
        let encryptedPassword = AESCrypt.encrypt(userPassword, password: HTTPHelper.API_AUTH_PASSWORD)
        httpRequest.HTTPBody = "{\"first_name\":\"\(firstName)\",\"last_name\":\"\(lastName)\",\"email\":\"\(userEmail)\",\"password\":\"\(encryptedPassword)\"}".dataUsingEncoding(NSUTF8StringEncoding)
        self.httpHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage)
                return
            }
            self.toggleUserForms()
            self.displayAlertMessage("Success", alertDescription: "Account has been created")
        })
    }
    
    func makeSignInRequest(userEmail:String, userPassword:String) {
        let httpRequest = httpHelper.buildRequest("signin", method: "POST", authType: HTTPRequestAuthType.HTTPBasicAuth)
        let encryptedPassword = AESCrypt.encrypt(userPassword, password: HTTPHelper.API_AUTH_PASSWORD)
        httpRequest.HTTPBody = "{\"email\":\"\(userEmail)\",\"password\":\"\(encryptedPassword)\"}".dataUsingEncoding(NSUTF8StringEncoding);
        httpHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage)
                return
            }
        // hide activityIndicator and update userLoggedInFlag
        self.activityIndicator.fadeOut(duration: 0.0)
        self.updateUserLoggedInFlag()
        
        var jsonerror:NSError?
        let responseDict = NSJSONSerialization.JSONObjectWithData(data,
        options: NSJSONReadingOptions.AllowFragments, error:&jsonerror) as! NSDictionary
        var stopBool : Bool
        
        // save API AuthToken and ExpiryDate in Keychain
        self.saveApiTokenInKeychain(responseDict)
        })
    }
    
    func updateUserLoggedInFlag() {
        // Update the NSUserDefaults flag
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("loggedIn", forKey: "userLoggedIn")
        defaults.synchronize()
    }
    
    func saveApiTokenInKeychain(tokenDict:NSDictionary) {
        // Store API AuthToken and AuthToken expiry date in KeyChain
        tokenDict.enumerateKeysAndObjectsUsingBlock({ (dictKey, dictObj, stopBool) -> Void in
            var myKey = dictKey as! NSString
            var myObj = dictObj as! NSString
            
            if myKey == "api_authtoken" {
                KeychainAccess.setPassword(myObj as String, account: "Auth_Token", service: "KeyChainService")
            }
            
            if myKey == "authtoken_expiry" {
                KeychainAccess.setPassword(myObj as String, account: "Auth_Token_Expiry", service: "KeyChainService")
            }
        })
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func toggleForms(sender: UIButton) {
        toggleUserForms()
    }
    
    func toggleUserForms() {
        signinView.toggleFade(duration: 0.3)
        signupView.toggleFade(duration: 0.3, completion: {
            (finished: Bool) -> Void in
            self.clearFields()
        })
    }
    
    func clearFields() {
        for view in [signinView, signupView] as [UIView] {
            for field in view.subviews {
                if let textField = field as? UITextField {
                    textField.text = nil
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
