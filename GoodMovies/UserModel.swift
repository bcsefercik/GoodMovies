import Foundation
import Firebase

class UserModel{
    
    static func getUserWithID(id: String)->User{
        var user: User?
        FirebaseModel.dataAtEndpoint("users/\(id)") { (data) -> Void in
            
            if let json = data as? [String: AnyObject] {
                user = User(json: json, id: id)
                
            } else {
                user = nil
            }
        }
        
        return user!
    }
}