import Foundation

struct Movie: Equatable {

    let name: String
    let year: String
    let imdbID: String
    let poster: NSURL
    var status: MovieStatus
    
    mutating func setStatus(newStatus: MovieStatus){
        status = newStatus
    }
    
    init(name: String, year: String, imdbID: String, poster: String, status: MovieStatus) {
        self.name = name
        self.imdbID = imdbID
        let posterString = poster.stringByReplacingOccurrencesOfString("@@._V1_SX300.jpg", withString: "@@._V1_SX90.jpg")
        self.poster = NSURL(string: posterString)!
        self.year = year
        self.status = status
    }
    init(name: String, year: String, imdbID: String, poster: String){
        self.init(name: name, year: year, imdbID: imdbID, poster: poster, status: MovieStatus.none)
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
