import Foundation

class UserTransaction {
    private let database = DatabaseAdapter()
    func addMovie(movie: Movie){
        var movieStatus = "willWatch"
        if movie.status == MovieStatus.didWatch {
            movieStatus = "didWatch"
        }
        let data = ["title": movie.name,
                    "poster": movie.poster.absoluteString,
                    "year": movie.year,
                    "date": -NSDate().timeIntervalSince1970]
        
        let path = "users/\(database.uid!)/movies/"
        
        database.delete(movie.imdbID, path: "\(path)/didWatch"){ [](_) in
            self.database.delete(movie.imdbID, path: "\(path)/willWatch"){ (_) in
                self.database.insert(movie.imdbID, path: "\(path)\(movieStatus)", values: data as! [String : AnyObject])
            }
        }
    }
    
    func fetchUserMovies(userID: String, type: MovieStatus, completion: (DBResponse, movies: [Movie]) -> Void){
        
    }
    
    func fetch(){
    }
    
    func fetchUserInfo(userID: String, completion: (User) -> Void){
        let realUserID = userID.stringByReplacingOccurrencesOfString(UserConstants.currentUserID, withString: database.uid!)
        database.fetchDict(realUserID, path: "users/"){ (response, values) in
            switch response {
            case .success:
                print(values)
            default:
                return
            }
            return
        }
        
    }
    
    
    
}