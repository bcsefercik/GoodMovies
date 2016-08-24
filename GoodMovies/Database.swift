
import Foundation
import Firebase

class DatabaseAdapter {
    
    let base = FIRDatabase.database().referenceFromURL("https://goodmovies-e9b7c.firebaseio.com/")
    
    func insert(key: String, path: String, values: [String: AnyObject]){
        let ref = base.child(path).child(key)
        ref.updateChildValues(values)
    }
    
    
    func fetch(filter: String, path: String, completion: (DBResponse, [String]) -> Void){
        let ref = base.child(path).queryOrderedByChild("status").queryEqualToValue("willWatch").queryLimitedToFirst(1)
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