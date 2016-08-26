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
    
    func fetchUserInfo(userID: String, completion: (User?, NetworkResult) -> Void){
        let realUserID = userID.stringByReplacingOccurrencesOfString(UserConstants.currentUserID, withString: database.uid!)
        database.fetchDict(realUserID, path: "users/"){ (response, val) in
            switch response {
            case .success:
                guard let values = val as? [String:String] else {
                    completion(nil,.error)
                    return
                }
                
                let user = User(uid: realUserID, username: values["username"], name: values["name"], movieCount: Int(values["movieCount"]!), followerCount: Int(values["followerCount"]!), followingCount: Int(values["followingCount"]!))
                completion(user, NetworkResult.success)
            default:
                completion(nil,.error)
            }
            return
        }
        
    }
    
    
    
}