//
//  RegisterViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 15/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loading: LoadingView!
    
    
    private let model = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }

        
        setupForm()
        
        loading = addLoading()
        loading.setLabel("Signing up...")
    }
    
    
    @IBAction func registerButtonTapped(sender: UIButton) {
        handleRegister()
    }
    
    func handleRegister(){
        
        guard let mail = mailField.text, password = passwordField.text, name = nameField.text, username = usernameField.text else{
            applyStateChange(.emptyError)
            return
        }
        
        registerButton.enabled = false
        loading.showIn(true)
        
        self.model.signUp(mail, password: password, username: username, name: name)
    }
    
    func applyStateChange(change: RegisterViewModel.RegisterState.Change) {
        switch change{
            
        case .emptyError:
            registerAlert("", text: "All fields are required.")
            registerButton.enabled = true
            loading.hide(true)
        case .invalidEmailError:
            registerAlert("Invalid Email", text: "Please enter a correct email address.")
            registerButton.enabled = true
            loading.hide(true)
        case .takenEmailError:
            registerAlert("", text: "This email address is already registered.")
            registerButton.enabled = true
            loading.hide(true)
        case .takenUsernameError:
            registerAlert("", text: "This username is already taken.")
            registerButton.enabled = true
            loading.hide(true)
        case .dbError:
            let alert = UIAlertController(
                title: "Something went wrong...",
                message: "Please correct your inputs.",
                preferredStyle: .Alert
            )
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            
            registerButton.enabled = true
            loading.hide(true)
        case .registered:
            
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
            registerButton.enabled = true
            loading.hide(true)
        }

    }
    
    
    func setupForm(){
        mailField!.delegate = self
        passwordField!.delegate = self
        usernameField!.delegate = self
        nameField!.delegate = self
        
        
        registerButton.canResignFirstResponder()
        registerButton.backgroundColor = Color.wetAsphalt
        registerButton.tintColor = Color.clouds
        registerButton.layer.borderWidth = 0
        registerButton.layer.cornerRadius = 6
        registerButton.heightAnchor.constraintEqualToConstant(39).active = true
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === usernameField) {
            nameField.becomeFirstResponder()
        } else if (textField == nameField){
            mailField.becomeFirstResponder()
        } else if (textField == mailField){
            passwordField.becomeFirstResponder()
        } else if (textField === passwordField) {
            passwordField.resignFirstResponder()
            handleRegister()
        }
        
        return true
    }
    
    private func registerAlert(title: String, text: String){
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .Alert
        )
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
        

    }


}
