import Foundation
import Firebase

class RegisterViewModel{
    
    struct RegisterState {
    }
    
    private(set) var state = RegisterState()
    var stateChangeHandler: ((RegisterState.Change) -> Void)?
    
    func signUp(email: String, password: String, username: String, name: String){
        
        if (email == "" || password == "" || username == "" || name == ""){
            self.stateChangeHandler?(RegisterState.Change.emptyError)
            return
        }
        
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                switch error!.code{
                case FIRAuthErrorCode.ErrorCodeInvalidEmail.rawValue:
                    self.stateChangeHandler?(RegisterState.Change.invalidEmailError)
                case FIRAuthErrorCode.ErrorCodeEmailAlreadyInUse.rawValue:
                    self.stateChangeHandler?(RegisterState.Change.takenEmailError)
                default:
                    self.stateChangeHandler?(RegisterState.Change.dbError)
                    
                }
                
                return
            }
            
            guard let uid = user?.uid else {
                self.stateChangeHandler?(RegisterState.Change.dbError)
                return
            }
            
            let ref = FIRDatabase.database().referenceFromURL("https://mymovies-e0a6f.firebaseio.com/")
            let usersReference = ref.child("users").child(uid)
            let values = ["name": name.lowercaseString, "email": username, "username": email.stringByReplacingOccurrencesOfString("@mymoviesapp.com", withString: ""), "profilePicture": "empty", "followerCount": 0, "followingCount": 0, "fgColor": "0,0,0", "bgColor": "255,255,255"]
            usersReference.updateChildValues(values as [NSObject : AnyObject], withCompletionBlock: { (err, ref) in
                
                if err != nil {
                    self.stateChangeHandler?(RegisterState.Change.dbError)
                    return
                }
                
            })
            FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
                
                if error != nil {
                    self.stateChangeHandler?(RegisterState.Change.dbError)
                    return
                }
                
                self.stateChangeHandler?(RegisterState.Change.registered)
                
            })

            
            
            return
        })
        
    }
}

extension RegisterViewModel.RegisterState{
    enum Change {
        case emptyError
        case invalidEmailError
        case takenEmailError
        case takenUsernameError
        case dbError
        case registered
    }
}