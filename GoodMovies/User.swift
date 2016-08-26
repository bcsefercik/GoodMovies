import Foundation
struct User{
    let uid: String?
    let username: String?
    let name: String?
    let willWatchCount: Int?
    let didWatchCount: Int?
    let followerCount: Int?
    let followingCount: Int?
}

struct UserConstants{
    static let currentUserID = "currentUserID"
}