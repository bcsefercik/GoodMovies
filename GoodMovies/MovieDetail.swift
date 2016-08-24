import Foundation

struct MovieDetail: Equatable {
    

    
    let name: String
    let year: String
    let imdbID: String
    let releaseDate: String
    let duration: String
    let genre: String
    let director: String
    let writer: String
    let actors: String
    let plot: String
    let poster: NSURL
    let posterBig: NSURL
    let rating: String
    let language: String
    let country: String
    let awards: String
    let status: MovieStatus
    
    init(name: String, year: String, imdbID: String, poster: String, releaseDate: String, duration: String, genre: String, director: String, writer: String, actors: String, plot: String, rating: String, language: String, country: String, awards: String, status: MovieStatus) {
        
        self.name = name
        self.imdbID = imdbID
        let posterString = poster.stringByReplacingOccurrencesOfString("@._V1_SX300.jpg", withString: "@._V1_SX2600.jpg")
        self.posterBig = NSURL(string: posterString)!
        self.poster = NSURL(string: poster)!
        self.year = year
        self.releaseDate = releaseDate
        self.duration = duration
        self.genre = genre
        self.director = director
        self.writer = writer
        self.actors = actors
        self.plot = plot
        self.rating = rating
        self.status = status
        self.language = language
        self.country = country
        self.awards = awards
    }
}

// MARK: MovieDetail Equatable

func ==(lhs: MovieDetail, rhs: MovieDetail) -> Bool {
    return lhs.imdbID == rhs.imdbID
}
