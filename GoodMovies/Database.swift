
import Foundation
import Firebase

class DatabaseAdapter {
    
    let base = FIRDatabase.database().referenceFromURL("https://goodmovies-e9b7c.firebaseio.com/")
    
    func insert(key: String, path: String, values: [String: AnyObject]){
        let ref = base.child(path).child(key)
        ref.updateChildValues(values)
    }
}
