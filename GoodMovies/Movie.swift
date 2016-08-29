import Foundation

struct Movie: Equatable {

    let name: String
    let year: String
    let imdbID: String
    let poster: NSURL
    var status: MovieStatus
    var date: Double
    
    mutating func setStatus(newStatus: MovieStatus){
        status = newStatus
    }
    
    init(name: String, year: String, imdbID: String, poster: String, status: MovieStatus, date: Double) {
        self.name = name
        self.imdbID = imdbID
        let posterString = poster.stringByReplacingOccurrencesOfString("@@._V1_SX300.jpg", withString: "@@._V1_SX90.jpg")
        self.poster = NSURL(string: posterString)!
        self.year = year
        self.status = status
        self.date = date
    }
    init(name: String, year: String, imdbID: String, poster: String){
        self.init(name: name, year: year, imdbID: imdbID, poster: poster, status: MovieStatus.none, date: NSDate().timeIntervalSince1970)
    }
    init(name: String, year: String, imdbID: String, poster: String, status: MovieStatus){
        self.init(name: name, year: year, imdbID: imdbID, poster: poster, status: status, date: NSDate().timeIntervalSince1970)
    }
}

enum MovieStatus{
    case none
    case willWatch
    case didWatch
}

// MARK: Movie Equatable

func ==(lhs: Movie, rhs: Movie) -> Bool {
    return lhs.imdbID == rhs.imdbID
}
