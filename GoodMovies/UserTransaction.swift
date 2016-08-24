import Foundation
import Firebase

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
                    "status": movieStatus,
                    "date": NSDate().timeIntervalSince1970]
        
        database.insert(movie.imdbID, path: "users/\((FIRAuth.auth()?.currentUser?.uid)!)/movies", values: data as! [String : AnyObject])
    }
    
    func fetchUserMovies(userID: String, type: MovieStatus, completion: (DBResponse, movies: [Movie]) -> Void){
        
    }
    
    func fetch(){
        database.fetch("willwatch", path: "users/\((FIRAuth.auth()?.currentUser?.uid)!)/movies"){ (_,_) in
            
        }
    }
}