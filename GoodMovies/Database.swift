
import Foundation
import Firebase

class DatabaseAdapter {
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    let base = FIRDatabase.database().referenceFromURL("https://mymovies-e0a6f.firebaseio.com/")
    
    func insert(key: String, path: String, values: [String: AnyObject], completion: ((DBResponse) -> Void)?){
        let ref = base.child(path).child(key)
        ref.updateChildValues(values){ _,_ in 
            completion?(DBResponse.success)
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
    
    func fetch(key: String, orderBy: String?, path: String, completion: (DBResponse, [[String:String]]) -> Void){
        var result: [[String:String]] = []
        var ref: FIRDatabaseQuery
        if orderBy != nil {
            ref = base.child("\(path)\(key)/").queryOrderedByChild(orderBy!)
        } else {
            ref = base.child("\(path)\(key)/")
        }
        
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            if !snapshot.exists(){
                completion(.fail("empty"), [[String:String]]())
            } else {
                for snap in snapshot.children.allObjects {
                    var r: [String:String] = [:]
                    var value: String?
                    for s in snap.children.allObjects{
                        let key = s.key!!
                        if key == "date" {
                            value = String(format: "%f", s.value.doubleValue)
                        } else {
                            value = s.value!!
                        }
                        r.updateValue(value!, forKey: key)
                    }
                    r.updateValue(snap.key!!, forKey: "mainKey")
                    result.append(r)
                }
                completion(.success, result)
            }
            return
        })
    }
    
    func fetchDict(key: String, path: String, completion: (DBResponse, [String:AnyObject]) -> Void){
        self.fetchDict(key, orderBy: nil, path: path, completion: completion)
    }
    
    func fetchDict(key: String, orderBy: String?, path: String, completion: (DBResponse, [String:AnyObject]) -> Void){
        var result: [String:String] = [:]
        var ref: FIRDatabaseQuery
        
        if orderBy != nil {
            ref = base.child("\(path)/\(key)/").queryOrderedByChild(orderBy!)
        } else {
            ref = base.child("\(path)/\(key)/")
        }
        
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
    
    func fetchKeys(path: String, completion: ((DBResponse,[String]) -> Void)?){
        var result: [String] = []
        let ref = base.child(path)
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if !snapshot.exists(){
                completion?(.error(.serverError), [String]())
            } else {
                for snap in snapshot.children.allObjects {
                    let mainKey = snap.key!!
                    result.append(mainKey)
                }
                completion?(.success, result)
            }
            return
            
        })
    }
    
    func searchKeyStartings(key:String, path: String, completion: ((DBResponse,[String]) -> Void)?){
        var result: [String] = []
        let ref = base.child(path).queryOrderedByKey().queryStartingAtValue(key)
        ref.observeEventType(.Value, withBlock: { snapshot in
            if !snapshot.exists(){
                completion?(.error(.serverError), [String]())
            } else {
                for snap in snapshot.children.allObjects {
                    let mainKey = snap.key!!
                    result.append(mainKey)
                }
                completion?(.success, result)
            }
            return
            
        })
    }
    
    func searchDict(text: String, key: String, path: String, completion: (DBResponse, [String:AnyObject]) -> Void){
        var result: [String:AnyObject] = [:]
        let ref = base.child("\(path)").queryOrderedByChild(key).queryStartingAtValue(text)
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            if !snapshot.exists(){
                completion(.error(.serverError), [String:AnyObject]())
            } else {
                for snap in snapshot.children.allObjects {
                    let mainKey = snap.key!!
                    var val: [String:String] = [:]
                    for s in snap.children.allObjects {
                        let k = s.key!!
                        let v = s.value!!
                        val.updateValue(v, forKey: k)
                    }
                    result.updateValue(val, forKey: mainKey)
                }
                
                completion(.success, result)
            }
            return
        })
    }
    
    func nodeCount(path: String, completion: (UInt, DBResponse) -> Void){
        let ref = base.child("\(path)")
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if !snapshot.exists(){
                completion(0,.success)
            } else {
                completion(snapshot.childrenCount,.success)
            }
        })
    }
}

enum DBResponse: Equatable{
    case success
    case fail(String)
    case error(DBResponseError)
}
func ==(lhs: DBResponse, rhs: DBResponse)->Bool{
    switch lhs {
    case .success:
        switch rhs {
        case .success:
            return true
        default:
            return false
        }
    case .fail(let lstr):
        switch rhs {
        case .fail(let rstr):
            return lstr == rstr
        default:
            return false
        }
    case .error(let le):
        switch rhs {
        case .error(let re):
            return le == re
        default:
            return false
        }
    }
}

enum DBResponseError: Equatable{
    case incomplete
    case empty
    case serverError
}
