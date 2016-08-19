import Foundation

struct Movie: Equatable {
    
    private struct Const {
        
        struct Year {
            static let min = UInt(1800)
            static let max = UInt(2100)
        }
    }
    
    let name: String
    let year: String
    let imdbID: String
    let poster: NSURL
    
    init(name: String, year: String, imdbID: String, poster: String) {
        
        self.name = name
        self.imdbID = imdbID
        let posterString = poster.stringByReplacingOccurrencesOfString("@@._V1_SX300.jpg", withString: "@")
        self.poster = NSURL(string: posterString)!
        self.year = year
    }
}

// MARK: Movie Equatable

func ==(lhs: Movie, rhs: Movie) -> Bool {
    return lhs.imdbID == rhs.imdbID
}
