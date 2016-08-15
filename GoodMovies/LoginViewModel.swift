//
//  UserViewModel.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 12/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import Foundation
import Firebase

class LoginViewModel{
    
    struct LoginState {
    }
    
    private(set) var state = LoginState()
    var stateChangeHandler: ((LoginState.Change) -> Void)?
    
    func signIn(email: String, password: String){
        
        if (email=="" || password==""){
            self.stateChangeHandler?(LoginState.Change.emptyError)
            return
        }
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            
            if error != nil {
                self.stateChangeHandler?(LoginState.Change.dbError)
                return
            }
            
            self.stateChangeHandler!(LoginState.Change.loggedIn)
            
        })
        
    }
}

extension LoginViewModel.LoginState{
    enum Change {
        case loggedIn
        case emptyError
        case dbError
    }
}