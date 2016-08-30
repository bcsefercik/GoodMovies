import Foundation
struct User{
    let uid: String
    let username: String
    let name: String
    let willWatchCount: Int?
    let didWatchCount: Int?
    let followerCount: Int?
    let followingCount: Int?
    let picture: NSURL?
}


struct UserSimple{
    let name, username, uid: String
    let picture: NSURL?
    
    init(name: String, username: String, uid: String, picture: String){
        self.name = name
        self.username = username
        self.uid = uid
        self.picture = NSURL(string: picture)!
    }
}


struct UserConstants{
    static let currentUserID = "currentUserID"
}