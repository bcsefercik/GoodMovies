import Foundation

class UserTransaction {
    private let database = DatabaseAdapter()
    private let defaultPicture = "http://staffprofiles.bournemouth.ac.uk/library/images/nopicture-male.jpg"
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

        database.delete(movie.imdbID, path: "\(path)/didWatch"){ (_) in
            self.database.delete(movie.imdbID, path: "\(path)/willWatch"){ (_) in
                self.database.insert(movie.imdbID, path: "\(path)\(movieStatus)", values: data as! [String : AnyObject]){ _ in
                    
                }
            }
        }
    }
    
    func addMovie(movie: Movie){
        addMovie(movie, completion: nil)
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
                        self.database.nodeCount("users/\(realUserID)/followers/"){ count,_ in
                            userInfo.updateValue(String(count), forKey: "followerCount")
                            self.database.nodeCount("users/\(realUserID)/following/"){ count,_ in
                                userInfo.updateValue(String(count), forKey: "followingCount")
                                guard let uUsername = userInfo["username"], uName = userInfo["name"], uWillWatchCount = userInfo["willWatchCount"], uDidWatchCount = userInfo["didWatchCount"], uFollowerCount = userInfo["followerCount"], uFollowingCount = userInfo["followingCount"], uPicture = userInfo["profilePicture"]?.stringByReplacingOccurrencesOfString("empty", withString: self.defaultPicture) else {
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
                                
                                let user = User(uid: realUserID, username: uUsername, name: uName, willWatchCount: Int(uWillWatchCount), didWatchCount: Int(uDidWatchCount), followerCount: Int(uFollowerCount), followingCount: Int(uFollowingCount), picture: uPicture, foregroundColor: uFgColor, backgroundColor: uBgColor)
                                
                                completion(user,finalResponse)
                                return
                            }
                            return
                        }
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
        database.fetchDict(followerID, path: "users/\(userID)/followers/"){ response,_ in
            if response == .success {
                completion?(response,true)
            } else {
                completion?(response,false)
            }
            return
        }
    }
    
}