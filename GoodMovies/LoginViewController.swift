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
    
    private let loading = LoadingOverlay.shared
    
    private let model = LoginViewModel()
    private let router = LoginRegisterRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        setupForm()
    }
    
    func applyStateChange(change: LoginViewModel.LoginState.Change) {
        switch change{
        case .loggedIn:
            loading.hideOverlayView()
            router.goToMain()
        case .emptyError:
            PopupMessage.shared.showMessage(self.view, text: "All fields are required.", type:  .error)
            loginButton.enabled = true
            loading.hideOverlayView()
        case .dbError:
            PopupMessage.shared.showMessage(self.view, text: "The email address and password you entered did not match our recors. Please double check and try again.", type:  .error)
            loginButton.enabled = true
            loading.hideOverlayView()
        }
        
    }
    
    func handleLogin(){
        let mail = mailField.text!
        let password = passwordField.text!
        
        loginButton.enabled = false
        loading.showOverlay(self.view, text: "Loading...")
        
        self.model.signIn(mail, password: password)
    }
    
    @IBAction func goToRegister(sender: UIButton) {
        router.goToRegister()
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



