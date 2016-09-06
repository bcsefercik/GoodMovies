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
            self.database.delete(movie.imdbID, path: "\(path)/willWatch"){ response in
                
                if movie.status != .none {
                    self.database.insert(movie.imdbID, path: "\(path)\(movieStatus)", values: data as! [String : AnyObject]){ response in
                        
                        completion?(response)
                        self.fetchUserInfo(self.database.uid!){ userInfo,response in
                            if response == .success{
                                guard let user = userInfo else {
                                    //TODO: error
                                    return
                                }
                                self.database.fetchKeys("followers/\(self.database.uid!)/"){ response,result in
                                    for r in result{
                                        self.database.insert("\(self.database.uid!)_\(movie.imdbID)", path: "timelines/\(r)/", values: ["userID": user.uid, "username": user.username, "profilePicture": (user.picture?.absoluteString)!, "imdbID": movie.imdbID, "moviePoster": movie.poster.absoluteString, "movieName": movie.name, "movieYear": movie.year, "date": -movie.date, "status": "willWatch"]){ response in
                                            if response == .success {
                                            } else {
                                                //TODO: error
                                            }
                                        }
                                    }
                                }
                            } else {
                                //TODO: error
                            }
                        }
                    }

                } else {
                    completion?(response)
                }
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
                        //TODO: error
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
                        self.database.nodeCount("followers/\(realUserID)/"){ count,_ in
                            userInfo.updateValue(String(count), forKey: "followerCount")
                            self.database.nodeCount("following/\(realUserID)/"){ count,_ in
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
                                
                                let user = User(uid: realUserID, username: uUsername, name: uName, willWatchCount: Int(uWillWatchCount)!, didWatchCount: Int(uDidWatchCount)!, followerCount: Int(uFollowerCount), followingCount: Int(uFollowingCount), picture: uPicture, foregroundColor: uFgColor, backgroundColor: uBgColor)
                                
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
                                                            //TODO: error
                                                            print("error6")
                                                            break
                                                        }
                                                    }

                                                } else {
                                                    //TODO: error
                                                    print("error5")
                                                }
                                            }
                                        }
                                    default:
                                        //TODO: error
                                        print("error4")
                                    break
                                    }
                                }
                            default:
                                //TODO: error
                                print("error3")
                                break
                            }
                        }
                    default:
                        //TODO: error
                        print("error2")
                        break
                    }
                    
                }
            default:
                //TODO: error
                print("error1")
                break
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
                            switch response{
                            case .success:
                                strongSelf.database.searchKeyStartings("\(toUnfollow.uid)_", path: "timelines/\(strongSelf.cUserID)/"){ response,result in
                                    if response == .success {
                                        for r in result {
                                            strongSelf.database.delete(r, path: "timelines/\(strongSelf.cUserID)/")
                                        }
                                    } else {
                                        //TODO: error
                                    }
                                }
                            default:
                                //TODO: error
                                break
                            }
                        }
                    default:
                        //TODO: error
                        break
                    }
                    
                }
            default:
                //TODO: error
                break
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
}