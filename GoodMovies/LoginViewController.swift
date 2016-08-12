//
//  UserViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 12/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
    }
    
    
    
    func setupForm(){
        
        loginButton.canResignFirstResponder()
        loginButton.setTitle("LOGIN", forState: .Normal)
        loginButton.backgroundColor = Color.wetAsphalt
        loginButton.tintColor = Color.clouds
        loginButton.layer.borderWidth = 0
        loginButton.layer.cornerRadius = 6
        loginButton.heightAnchor.constraintEqualToConstant(39).active = true
    }

}


