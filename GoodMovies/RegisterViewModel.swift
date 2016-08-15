import Foundation
import Firebase

class RegisterViewModel{
    
    struct RegisterState {
    }
    
    private(set) var state = RegisterState()
    var stateChangeHandler: ((RegisterState.Change) -> Void)?
    
    func signIn(email: String, password: String){
        
        if (email=="" || password==""){
            self.stateChangeHandler?(RegisterState.Change.emptyError)
            return
        }
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            
            if error != nil {
                self.stateChangeHandler?(RegisterState.Change.dbError)
                return
            }
            
            self.stateChangeHandler!(RegisterState.Change.loggedIn)
            
        })
        
    }
}

extension RegisterViewModel.RegisterState{
    enum Change {
        case loggedIn
        case emptyError
        case dbError
    }
}