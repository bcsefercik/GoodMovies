import Foundation

struct Movie: Equatable {
    
    private struct Const {
        
        struct Year {
            static let min = UInt(1800)
            static let max = UInt(2100)
        }
    }
    
    let name: String
    let year: UInt
    let imdbID: String
    let poster: NSURL
    
    init(name: String, year: UInt, imdbID: String, poster: String) {
        
        self.name = name
        self.imdbID = imdbID
        self.poster = NSURL(string: poster)!
        
        if year > Const.Year.max {
            self.year = Const.Year.max
        }
        else if year < Const.Year.min {
            self.year = Const.Year.min
        }
        else {
            self.year = year
        }
        
    }
}

// MARK: Movie Equatable

func ==(lhs: Movie, rhs: Movie) -> Bool {
    return lhs.imdbID == rhs.imdbID
}
