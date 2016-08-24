import Foundation
import Firebase

class UserTransactions {
    private let database = DatabaseAdapter()
    func addMovie(){
        database.insert("tt131352", path: "users/\((FIRAuth.auth()?.currentUser?.uid)!)", values: ["title": "The Social Network"])
    }
}