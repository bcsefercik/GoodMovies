
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
    
    
    func fetch(key: String, path: String, completion: (DBResponse, [String]) -> Void){
        let ref = base.child("\(path)/willWatch").queryOrderedByChild("date")
        ref.observeEventType(.ChildAdded, withBlock: { snapshot in
            
            print(snapshot.value! as! [String : AnyObject])
            completion(.success, [String]())
        })

    }
    
    
}

enum DBResponse{
    case success
    case fail(String)
}