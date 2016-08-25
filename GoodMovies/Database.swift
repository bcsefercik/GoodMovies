
import Foundation
import Firebase

class DatabaseAdapter {
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    let base = FIRDatabase.database().referenceFromURL("https://goodmovies-e9b7c.firebaseio.com/")
    
    func insert(key: String, path: String, values: [String: AnyObject]){
        let ref = base.child(path).child(key)
        ref.updateChildValues(values)
    }
    
    func delete(key: String, path: String){
        self.delete(key, path: path){ (_) in }
    }
    
    func delete(key: String, path: String, completion: (DBResponse) -> Void){
        let ref = base.child(path).child(key)
        ref.removeValueWithCompletionBlock{ (error, _) in
            if error != nil {
                completion(.fail("fail"))
            } else {
                completion(.success)
            }
        }
    }
    
    
    func fetchDict(key: String, path: String, completion: (DBResponse, [String:String]) -> Void){
        var result: [String:String] = [:]
        let ref = base.child("\(path)/\(key)")
        ref.observeEventType(.Value, withBlock: { snapshot in
            if !snapshot.exists(){
                completion(.fail("empty"), [String:String]())
            } else {
                for snap in snapshot.children.allObjects {
                    result.updateValue(snap.value!, forKey: snap.key!!)
                }
                completion(.success, result)
            }
            return
        })
        
    }
    
    
}

enum DBResponse{
    case success
    case fail(String)
}