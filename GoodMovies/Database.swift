
import Foundation
import Firebase

class DatabaseAdapter {
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    let base = FIRDatabase.database().referenceFromURL("https://goodmovies-e9b7c.firebaseio.com/")
    
    func insert(key: String, path: String, values: [String: AnyObject], completion: (DBResponse) -> Void){
        let ref = base.child(path).child(key)
        ref.updateChildValues(values){ _,_ in 
            completion(DBResponse.success)
        }
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
    
    func increment(by: Int, path: String, completion: ((DBResponse) -> Void)?){
        let ref = base.child(path)
        ref.runTransactionBlock({
            (currentData:FIRMutableData!) in
            var value = currentData.value as? Int
            if value == nil {
                value = 0
            }
            currentData.value = value! + 1
            return FIRTransactionResult.successWithValue(currentData)
        }){_,_,_ in
            if completion != nil {
                completion!(.success)
                return
            }
            return
        }
    }
    
    func increment(by: Int, path: String){
        self.increment(by, path: path, completion: nil)
    }
    
    func fetchDict(key: String, path: String, completion: (DBResponse, [String:AnyObject]) -> Void){
        var result: [String:String] = [:]
        let ref = base.child("\(path)/\(key)")
        ref.observeEventType(.Value, withBlock: { snapshot in
            if !snapshot.exists(){
                completion(.fail("empty"), [String:AnyObject]())
            } else {
                for snap in snapshot.children.allObjects {
                    let val = snap.value!!
                    result.updateValue(val, forKey: snap.key!!)
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