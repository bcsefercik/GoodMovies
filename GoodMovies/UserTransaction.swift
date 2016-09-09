import Foundation
import UIKit
import FirebaseAuth

class UserTransaction {
    private let database = DatabaseAdapter()
    private let storage = StorageAdapter()
    
    private let defaultPicture = "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4"
    var cUserID: String {
        get {
            return database.uid!
        }
    }
    func addMovie(movie: Movie, completion: ((DBResponse) ->  Void)?){
        var movieStatus = "willWatch"
        if movie.status == MovieStatus.didWatch {
            movieStatus = "didWatch"
        }
        let data = ["title": movie.name,
                    "poster": movie.poster.absoluteString,
                    "year": movie.year,
                    "date": -NSDate().timeIntervalSince1970]
        
        let path = "movies/\(database.uid!)/"
        
        if movie.status != .none {
        database.delete(movie.imdbID, path: "\(path)/didWatch"){ (_) in
            self.database.delete(movie.imdbID, path: "\(path)/willWatch"){ response in
                
                    self.database.insert(movie.imdbID, path: "\(path)\(movieStatus)", values: data as! [String : AnyObject]){ response in
                        
                        completion?(response)
                        self.fetchUserInfo(self.database.uid!){ userInfo,response in
                            if response == .success{
                                guard let user = userInfo else {
                                    completion?(.fail("failed"))
                                    return
                                }
                                self.database.fetchKeys("followers/\(self.database.uid!)/"){ response,result in
                                    for r in result{
                                        self.database.insert("\(self.database.uid!)_\(movie.imdbID)", path: "timelines/\(r)/", values: ["userID": user.uid, "username": user.username, "profilePicture": (user.picture?.absoluteString)!, "imdbID": movie.imdbID, "moviePoster": movie.poster.absoluteString, "movieName": movie.name, "movieYear": movie.year, "date": -movie.date, "status": (movie.status == .willWatch ? "willWatch" : "didWatch")]){ response in
                                            if response == .success {
                                            } else {
                                                completion?(.fail("failed"))
                                            }
                                        }
                                    }
                                }
                            } else {
                                completion?(.fail("failed"))
                            }
                        }
                    }

                }
            }
        } else {
            self.deleteMovie(movie.imdbID){ response in
                completion?(response)
            }
        }
    }
    
    func addMovie(movie: Movie){
        addMovie(movie, completion: nil)
    }
    
    func deleteMovie(imdbID: String, completion: ((DBResponse) ->  Void)?){
        self.database.delete(imdbID, path: "movies/\(self.database.uid!)/didWatch"){ (_) in
            self.database.delete(imdbID, path: "movies/\(self.database.uid!)/willWatch"){ _ in
                completion?(.success)
                self.fetchUserInfo(self.database.uid!){ userInfo,response in
                    if response == .success{
                        self.database.fetchKeys("followers/\(self.database.uid!)/"){ response,result in
                            for r in result{
                                self.database.delete("\(self.database.uid!)_\(imdbID)", path: "timelines/\(r)/")
                            }
                        }
                    } else {
                        completion?(.error(.incomplete))
                    }
                }

            }
        }

    }
    
    func fetchUserMovies(userID: String, type: MovieStatus, completion: (DBResponse, movies: [Movie]) -> Void){
        let realUserID = userID.stringByReplacingOccurrencesOfString(UserConstants.currentUserID, withString: database.uid!)
        var key: String
        
        switch type {
        case .didWatch:
            key = "didWatch"
        default:
            key = "willWatch"
        }
        
        database.fetch(key, orderBy: "date", path: "movies/\(realUserID)/"){ (response, values) in
            switch response {
            case .success:
                let movies = values.map{ (r) -> Movie in
                    let name = r["title"]!
                    let year = r["year"]!
                    let imdbID = r["mainKey"]!
                    let poster = r["poster"]!
                    let date: Double = -Double(r["date"]!)!
                    return Movie(name: name, year: year, imdbID: imdbID, poster: poster, status: type, date: date)
                }
                completion(.success, movies: movies)
            default:
                completion(.error(.empty), movies: [Movie]())
            }
        }
    }
    
    
    func fetchUserInfo(userID: String, completion: (User?, DBResponse) -> Void){
        let realUserID = userID.stringByReplacingOccurrencesOfString(UserConstants.currentUserID, withString: database.uid!)
        var userInfo: [String:String] = [:]
        var finalResponse = DBResponse.success
        
        database.fetchDict(realUserID, path: "users/"){ [unowned self] (response, val) in
            switch response {
            case .success:
                guard let values = val as? [String:String] else {
                    finalResponse = .error(.incomplete)
                    return
                }
                for v in values {
                    userInfo.updateValue(v.1, forKey: v.0)
                }
                self.database.nodeCount("movies/\(realUserID)/willWatch/"){ count,_ in
                    userInfo.updateValue(String(count), forKey: "willWatchCount")
                    self.database.nodeCount("movies/\(realUserID)/didWatch/"){ count,_ in
                        userInfo.updateValue(String(count), forKey: "didWatchCount")
                        guard let uUsername = userInfo["username"], uName = userInfo["name"], uEmail = userInfo["email"], uWillWatchCount = userInfo["willWatchCount"], uDidWatchCount = userInfo["didWatchCount"], uFollowerCount = userInfo["followerCount"], uFollowingCount = userInfo["followingCount"], uPicture = userInfo["profilePicture"]?.stringByReplacingOccurrencesOfString("empty", withString: self.defaultPicture) else {
                            finalResponse = .error(.empty)
                            completion(nil, finalResponse)
                            return
                        }
                        
                        var uFgColor, uBgColor: String
                        
                        if (userInfo["fgColor"] == nil || userInfo["bgColor"] == nil){
                            uFgColor = ""
                            uBgColor = ""
                        } else {
                            uFgColor = userInfo["fgColor"]!
                            uBgColor = userInfo["bgColor"]!
                        }
                        let user = User(uid: realUserID, username: uUsername, name: uName, willWatchCount: Int(uWillWatchCount)!, didWatchCount: Int(uDidWatchCount)!, followerCount: Int(uFollowerCount)!, followingCount: Int(uFollowingCount)!, picture: uPicture, foregroundColor: uFgColor, backgroundColor: uBgColor, email: uEmail)
                        
                        completion(user,finalResponse)
                        return
                    }
                    return
                }
            default:
                finalResponse = .error(.serverError)
            }
            return
        }
        
        
    }
    
    func fetchUserInfoSimple(userID: String, completion: (User?, DBResponse) -> Void){
        let realUserID = userID.stringByReplacingOccurrencesOfString(UserConstants.currentUserID, withString: database.uid!)
        var userInfo: [String:String] = [:]
        var finalResponse = DBResponse.success
        
        database.fetchDict(realUserID, path: "users/"){ [unowned self] (response, val) in
            switch response {
            case .success:
                guard let values = val as? [String:String] else {
                    finalResponse = .error(.incomplete)
                    return
                }
                for v in values {
                    userInfo.updateValue(v.1, forKey: v.0)
                }
                        guard let uUsername = userInfo["username"], uName = userInfo["name"], uEmail = userInfo["email"],  uFollowerCount = userInfo["followerCount"], uFollowingCount = userInfo["followingCount"], uPicture = userInfo["profilePicture"]?.stringByReplacingOccurrencesOfString("empty", withString: self.defaultPicture) else {
                            finalResponse = .error(.empty)
                            completion(nil, finalResponse)
                            return
                        }
                
                        let uWillWatchCount = "0", uDidWatchCount = "0"
                        
                        var uFgColor, uBgColor: String
                        
                        if (userInfo["fgColor"] == nil || userInfo["bgColor"] == nil){
                            uFgColor = ""
                            uBgColor = ""
                        } else {
                            uFgColor = userInfo["fgColor"]!
                            uBgColor = userInfo["bgColor"]!
                        }
                let user = User(uid: realUserID, username: uUsername, name: uName, willWatchCount: Int(uWillWatchCount)!, didWatchCount: Int(uDidWatchCount)!, followerCount: Int(uFollowerCount)!, followingCount: Int(uFollowingCount)!, picture: uPicture, foregroundColor: uFgColor, backgroundColor: uBgColor, email: uEmail)
                
                        completion(user,finalResponse)
         
            default:
                finalResponse = .error(.serverError)
            }
            return
        }
        
        
    }

    
    func followUser(toFollow: User, completion: ((DBResponse) -> Void)?){
        self.fetchUserInfo(self.cUserID){ [weak self] currentUser,response in
            guard let strongSelf = self else {
                return
            }
            switch response {
            case .success:
                strongSelf.database.insert(strongSelf.cUserID, path: "followers/\(toFollow.uid)/", values: ["name": currentUser!.name, "username": currentUser!.username, "profilePicture": currentUser!.picture!.absoluteString]){ response in
                    switch response{
                    case .success:
                        strongSelf.database.insert(toFollow.uid, path: "following/\(strongSelf.cUserID)/", values: ["name": toFollow.name, "username": toFollow.username, "profilePicture": toFollow.picture!.absoluteString]){ response in
                            strongSelf.database.increment(1, path: "users/\(strongSelf.database.uid!)/followingCount")
                            strongSelf.database.increment(1, path: "users/\(toFollow.uid)/followerCount")
                            completion!(.success)
                            switch response{
                            case .success:
                                strongSelf.fetchUserMovies(toFollow.uid, type: .willWatch){ response,movies in
                                    switch response {
                                    case .success, .error(.empty):
                                        for m in movies {
                                            strongSelf.database.insert("\(toFollow.uid)_\(m.imdbID)", path: "timelines/\(strongSelf.cUserID)/", values: ["userID": toFollow.uid, "username": toFollow.username, "profilePicture": (toFollow.picture?.absoluteString)!, "imdbID": m.imdbID, "moviePoster": m.poster.absoluteString, "movieName": m.name, "movieYear": m.year, "date": -m.date, "status": "willWatch"]){ response in
                                                if response == .success {
                                                    strongSelf.fetchUserMovies(toFollow.uid, type: .didWatch){ response,movies in
                                                        
                                                        switch response {
                                                        case .success, .error(.empty):
                                                            for m in movies {
                                                                strongSelf.database.insert("\(toFollow.uid)_\(m.imdbID)", path: "timelines/\(strongSelf.cUserID)/", values: ["userID": toFollow.uid, "username": toFollow.username, "profilePicture": (toFollow.picture?.absoluteString)!, "imdbID": m.imdbID, "moviePoster": m.poster.absoluteString, "movieName": m.name, "movieYear": m.year, "date": -m.date, "status": "willWatch"]){ response in
                                                                    
                                                                }
                                                            }
                                                        default:
                                                            completion?(.fail("failed"))
                                                        }
                                                    }

                                                } else {
                                                    completion?(.fail("failed"))
                                                }
                                            }
                                        }
                                    default:
                                        completion?(.fail("failed"))
                                    break
                                    }
                                }
                            default:
                                completion?(.fail("failed"))
                            }
                        }
                    default:
                        completion?(.fail("failed"))
                    }
                    
                }
            default:
                completion?(.fail("failed"))
            }
        }
    }
    
    func unfollowUser(toUnfollow: User, completion: ((DBResponse) -> Void)?){
        self.fetchUserInfo(self.cUserID){ [weak self] currentUser,response in
            guard let strongSelf = self else {
                return
            }
            switch response {
            case .success:
                strongSelf.database.delete(strongSelf.cUserID, path: "followers/\(toUnfollow.uid)/"){ response in
                    switch response{
                    case .success:
                        strongSelf.database.delete(toUnfollow.uid, path: "following/\(strongSelf.cUserID)/"){ response in
                            
                            completion?(.success)
                            strongSelf.database.increment(-1, path: "users/\(strongSelf.database.uid!)/followingCount")
                            strongSelf.database.increment(-1, path: "users/\(toUnfollow.uid)/followerCount")
                            switch response{
                            case .success:
                                strongSelf.database.searchKeyStartings("\(toUnfollow.uid)_", path: "timelines/\(strongSelf.cUserID)/"){ response,result in
                                    if response == .success {
                                        for r in result {
                                            strongSelf.database.delete(r, path: "timelines/\(strongSelf.cUserID)/")
                                        }
                                    } else {
                                        completion?(.fail("failed"))
                                    }
                                }
                            default:
                                completion?(.fail("failed"))
                            }
                        }
                    default:
                        completion?(.fail("failed"))
                    }
                    
                }
            default:
                completion?(.fail("failed"))
            }
        }
    }

    
    func searchUser(text: String, completion: (DBResponse, [String:[String:String]]?) -> Void){
        database.searchDict(text, key: "name", path: "users/"){ response1,result1 in
            if response1 == .success{
                guard let add1 = result1 as? [String : [String:String]] else {
                    completion(.error(.serverError), nil)
                    return
                }
                
                completion(.success, add1)
                return
            } else {
                completion(.error(.serverError), nil)
                return
            }
            
        }
    }
    
    func isFollowing(userID: String, followerID: String, completion: ((DBResponse, Bool) -> Void)?){
        database.fetchDict(followerID, path: "followers/\(userID)/"){ response,_ in
            if response == .success {
                completion?(response,true)
            } else {
                completion?(response,false)
            }
            return
        }
    }
    
    func isInMyList(imdbID: String, completion: (MovieStatus)->Void){
        database.doesExist("movies/\(database.uid!)/didWatch/\(imdbID)/"){ result in
            if result {
                completion(.didWatch)
            } else {
                self.database.doesExist("movies/\(self.database.uid!)/willWatch/\(imdbID)/"){ result in
                    if result {
                        completion(.willWatch)
                    } else {
                        completion(.none)
                    }
                }
            }
        }
    }
    
    func loadTimeline(completion: (DBResponse,[TimelineEntry]) -> Void){
        database.fetch(database.uid!, orderBy: "date", path: "timelines/"){ (response, values) in
            var entries: [TimelineEntry] = []
            switch response {
            case .success:
                entries = values.map{ (r) -> TimelineEntry in
                    let movieName = r["movieName"]!
                    let movieYear = r["movieYear"]!
                    let imdbID = r["imdbID"]!
                    let moviePoster = r["moviePoster"]!
                    let type = r["status"]!
                    let date: Double = -Double(r["date"]!)!
                    let username = r["username"]!
                    let userPicture = r["profilePicture"]!
                    let userID = r["userID"]!
                    return TimelineEntry(movieName: movieName, movieYear: movieYear, imdbID: imdbID, moviePoster: moviePoster, type: type, date: date, username: username, userPicture: userPicture, userID: userID)
                }
                completion(.success, entries)
            default:
                completion(.error(.empty),entries)
            }
        }

    }
    
    func uploadProfilePicture(imageView: UIImageView, completion: ((DBResponse,String) -> Void)?){
        if let profileImage = imageView.image, uploadData = UIImageJPEGRepresentation(profileImage, 0.78) {
            storage.upload("profile_pictures/", fileName: "\(self.cUserID).jpg", data: uploadData){ response,url in
                if response == .success {
                    self.database.insert(self.cUserID, path: "users/", values: ["profilePicture": url]){ response in
                        if response == .success {
                            self.database.fetchKeys("followers/\(self.database.uid!)/"){ response,result in
                                for r in result{
                                    self.database.searchKeyStartings("\(self.cUserID)_", path: "timelines/\(r)/"){ response,result in
                                        if response == .success {
                                            for rr in result {
                                                self.database.insert(rr, path: "timelines/\(r)/", values: ["profilePicture": url], completion: nil)
                                            }
                                        }
                                    }
                                }
                            }
                            completion?(.success,url)
                        } else {
                            completion?(.fail("failed"),"")
                        }
                    }
                } else {
                    completion?(.fail("failed"),"")
                }
            }
            
        } else {
            completion?(.fail("failed"),"")
            return
        }
    }
    
    func logout(completion: ((DBResponse) -> Void)?){
        do {
            try FIRAuth.auth()?.signOut()
            completion?(.success)
        } catch {
            completion?(.fail("error"))
        }
    }
    
    func setColor(color: String, type: String, completion:(() -> Void)?){
        database.insert(self.cUserID, path: "users/", values: [type: color]){ _ in
            completion?()
        }
    }
    
    func changePassword(userName: String, oldPassword: String, newPassword: String, newPasswordAgain: String, completion:((DBResponse) -> Void)?){
        
        FIRAuth.auth()?.signInWithEmail("\(userName)@mymoviesapp.com", password: oldPassword, completion: { (user, error) in
            
            if error != nil {
                completion?(.fail("Please correct your old password."))
                return
            }else{
                let user = FIRAuth.auth()?.currentUser
                
                user?.updatePassword(newPassword) { error in
                    if error != nil {
                        completion?(.fail("Something went wrong."))
                        return
                    } else {
                        completion?(.success)
                        return
                    }
                }
                return
            }
        })

    }
    
    func changeEmail(email:String, completion: ((DBResponse) -> Void)?){
        database.insert(self.cUserID, path: "users/", values: ["email": email]){ response in
            completion?(response)
        }
    }
}