//
//  UserViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 12/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loading: LoadingView!
    
    private let model = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        setupForm()
        
        loading = addLoading()
        loading.setLabel("Signing in...")
    }
    
    func applyStateChange(change: LoginViewModel.LoginState.Change) {
        switch change{
        case .loggedIn:
            print("LoginViewController: Succesfful login")
            loading.hide(true)
            
            
            self.dismissViewControllerAnimated(true, completion: nil)
            //Go to tabbar VC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabcon = storyboard.instantiateViewControllerWithIdentifier("TabBarVC") as! UITabBarController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            UIView.transitionWithView(appDelegate.window!, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled()
                UIView.setAnimationsEnabled(false)
                appDelegate.window?.rootViewController = tabcon
                UIView.setAnimationsEnabled(oldState)
                }, completion: nil)
            
            
        case .emptyError:
            let alert = UIAlertController(
                title: "",
                message: "All fields are required.",
                preferredStyle: .Alert
            )
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            
            loginButton.enabled = true
            loading.hide(true)
        case .dbError:
            let alert = UIAlertController(
                title: "Please try again...",
                message: "The email address and password you entered did not match our recors. Please double check and try again.",
                preferredStyle: .Alert
            )
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            
            loginButton.enabled = true
            loading.hide(true)
        }
        
    }
    
    func handleLogin(){
        let mail = mailField.text!
        let password = passwordField.text!
        
        loginButton.enabled = false
        loading.showIn(true)
        
        self.model.signIn(mail, password: password)
    }
    
    @IBAction func signInTapped(sender: UIButton) {
        handleLogin()
    }
    
    
    func setupForm(){
        mailField.delegate = self
        passwordField.delegate = self
        
        
        loginButton.canResignFirstResponder()
        loginButton.backgroundColor = Color.wetAsphalt
        loginButton.tintColor = Color.clouds
        loginButton.layer.borderWidth = 0
        loginButton.layer.cornerRadius = 6
        loginButton.heightAnchor.constraintEqualToConstant(39).active = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === mailField) {
            passwordField.becomeFirstResponder()
        } else if (textField === passwordField) {
            passwordField.resignFirstResponder()
            handleLogin()
        }
        
        return true
    }

}


extension UIViewController{
    func addLoading() -> LoadingView{
        let lv = UINib(nibName: "LoadingView", bundle:
            NSBundle(forClass:self.dynamicType)).instantiateWithOwner(nil,
                                                                      options: nil)[0] as! LoadingView
        
        self.view.addSubview(lv)
        
        lv.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: lv, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: lv, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        self.view.addConstraint(verticalConstraint)

        let views = ["lv": lv]
        
        let widthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[lv(130)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(widthConstraints)
        
        let heightConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[lv(130)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(heightConstraints)
        lv.layer.cornerRadius = 13
        lv.hide()
       return lv
    }
}



