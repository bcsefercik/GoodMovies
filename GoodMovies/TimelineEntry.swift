import Foundation
struct TimelineEntry: Equatable{
    
    let movieName: String
    let movieYear: String
    let imdbID: String
    let moviePoster: NSURL
    let type: MovieStatus
    let date: Double
    let username: String
    let userPicture: NSURL
    let userID: String

    
    init(movieName: String, movieYear: String, imdbID: String, moviePoster: String, type: String, date: Double, username: String, userPicture: String, userID: String) {
        self.movieName = movieName
        self.movieYear = movieYear
        self.imdbID = imdbID
        let posterString = moviePoster.stringByReplacingOccurrencesOfString("@@._V1_SX300.jpg", withString: "@@._V1_SX90.jpg")
        self.moviePoster = NSURL(string: posterString)!
        
        if type == "willWatch" {
            self.type = .willWatch
        } else {
            self.type = .didWatch
        }
        
        self.date = date
        self.username = username
        self.userPicture = NSURL(string: userPicture)!
        self.userID = userID
    }
}

func ==(lhs: TimelineEntry, rhs: TimelineEntry) -> Bool{
    if lhs.imdbID == rhs.imdbID && lhs.userID == rhs.userID{
        return true
    } else {
        return false
    }
}
