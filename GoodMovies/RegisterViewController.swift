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
    
    private let loading = LoadingOverlay.shared
    
    private let model = RegisterViewModel()
    private let router = LoginRegisterRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        setupForm()
    }
    
    
    @IBAction func registerButtonTapped(sender: UIButton) {
        handleRegister()
    }
    
    func handleRegister(){
        
        guard let mail = mailField.text, password = passwordField.text, name = nameField.text, username = usernameField.text else{
            applyStateChange(.emptyError)
            return
        }
        let email = username + "@mymoviesapp.com"
        
        registerButton.enabled = false
        loading.showOverlay(self.view, text: "Loading...")
        
        self.model.signUp(email, password: password, username: mail, name: name)
    }
    
    @IBAction func goToLogin(sender: UIButton) {
        router.goToLogin()
    }
    
    
    func applyStateChange(change: RegisterViewModel.RegisterState.Change) {
        switch change{
            
        case .emptyError:
            PopupMessage.shared.showMessage(self.view, text: "All fields are required.", type: .error)
            registerButton.enabled = true
            loading.hideOverlayView()
        case .invalidEmailError:
            PopupMessage.shared.showMessage(self.view, text: "Please enter a correct email address.", type: .error)
            registerButton.enabled = true
            loading.hideOverlayView()
        case .takenEmailError:
            PopupMessage.shared.showMessage(self.view, text: "This email address is already registered.", type: .error)
            registerButton.enabled = true
            loading.hideOverlayView()
        case .takenUsernameError:
            PopupMessage.shared.showMessage(self.view, text: "This username is already taken.", type: .error)
            registerButton.enabled = true
            loading.hideOverlayView()
        case .dbError:
            PopupMessage.shared.showMessage(self.view, text: "Something went wrong...", type: .error)            
            registerButton.enabled = true
            loading.hideOverlayView()
        case .registered:
            router.goToMain()
            registerButton.enabled = true
            loading.hideOverlayView()
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
            passwordField.becomeFirstResponder()
        } else if (textField == passwordField){
            mailField.becomeFirstResponder()
        } else if (textField == mailField){
            nameField.becomeFirstResponder()
        } else if (textField === nameField) {
            nameField.resignFirstResponder()
            handleRegister()
        }
        
        return true
    }



}
