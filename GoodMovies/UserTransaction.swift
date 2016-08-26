import Foundation

class UserTransaction {
    private let database = DatabaseAdapter()
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
        
    }
    
    func fetch(){
    }
    
    func fetchUserInfo(userID: String, completion: (User?, DBResponse) -> Void){
        let realUserID = userID.stringByReplacingOccurrencesOfString(UserConstants.currentUserID, withString: database.uid!)
        let dispatchGroup = dispatch_group_create()
        var userInfo: [String:String] = [:]
        var finalResponse = DBResponse.success
        dispatch_group_enter(dispatchGroup)
        
        print("Group 1")
        
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
                
                self.database.nodeCount("movies/\(realUserID)/willWatch/"){ count, response in
                    userInfo.updateValue(String(count), forKey: "willWatchCount")
                    self.database.nodeCount("movies/\(realUserID)/didWatch/"){ count, response in
                        userInfo.updateValue(String(count), forKey: "didWatchCount")
                        print(userInfo)
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
    
    
    
}