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
    let fgColor: String
    let bgColor: String
    
    init(uid: String, username: String, name: String, willWatchCount: Int?, didWatchCount: Int?, followerCount: Int?, followingCount: Int?, picture: String, foregroundColor: String, backgroundColor: String){
        self.uid = uid
        self.username = username
        self.name = name
        self.willWatchCount = willWatchCount
        self.didWatchCount = didWatchCount
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.picture = NSURL(string: picture)!
        self.fgColor = foregroundColor
        self.bgColor = backgroundColor
    }
    
    init(uid: String, username: String, name: String, willWatchCount: Int?, didWatchCount: Int?, followerCount: Int?, followingCount: Int?, picture: String){
        self.init(uid: uid, username: username, name: name, willWatchCount: willWatchCount, didWatchCount: didWatchCount, followerCount: followerCount, followingCount: followingCount, picture: picture, foregroundColor: "", backgroundColor: "")
    }
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