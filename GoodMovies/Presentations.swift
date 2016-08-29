import Foundation


struct MoviePresentation{
    let imdbID, title, year: String
    let poster: NSURL
}

struct ProfileMoviePresentation{
    let imdbID, title, year: String
    let poster: NSURL
    let userDate: Double
}