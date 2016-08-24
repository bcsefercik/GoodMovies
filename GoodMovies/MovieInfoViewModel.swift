import Foundation
import Firebase
import Alamofire

class MovieInfoViewModel{
    struct State {
        var loadingState = LoadingState()
        var movie: MovieDetail?
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    private let network = MovieInfoNetwork()
    private let usertransaction = UserTransaction()
    
    private var imdbID: String?
    
    func fetchMovie(imdbID: String){
        self.imdbID = imdbID
        
        let change = state.addActivity()
        emit(change)
        
        var fetchedMovie: MovieDetail?
        
        network.fetchMovie(imdbID){ [weak self] (response, result) in
            guard let strongSelf = self else {return}
            
            switch response {
            case .success:
                guard let name = result["Title"], year = result["Year"], poster = result["Poster"], released = result["Released"], duration = result["Runtime"], genre = result["Genre"], director = result["Director"], writer = result["Writer"], actors = result["Actors"], plot = result["Plot"], rating = result["imdbRating"], language = result["Language"], country = result["Country"], awards = result["Awards"] else { return }
                fetchedMovie = MovieDetail(name: name, year: year, imdbID: imdbID, poster: poster, releaseDate: released, duration: duration, genre: genre, director: director, writer: writer, actors: actors, plot: plot, rating: rating, language: language, country: country, awards: awards, status: .none)
                
                strongSelf.emit(strongSelf.state.loadMovie(fetchedMovie!))
                strongSelf.emit(strongSelf.state.removeActivity())
            default:
                break
            }
        }
    }
    
    func addToList(status: MovieStatus){
        usertransaction.fetch()
        guard let md = state.movie else { return }
        let movie = Movie(name: state.movie!.name , year: md.year, imdbID: md.imdbID, poster: md.poster.absoluteString, status: status)
        usertransaction.addMovie(movie)
    }
    
    func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}



extension MovieInfoViewModel.State {
    
    enum Change {
        case none
        case initialize
        case movie(MovieStatus)
        case loading(LoadingState)
    }
    
    mutating func addActivity() -> Change {
        
        loadingState.addActivity()
        return .loading(loadingState)
    }
    
    mutating func removeActivity() -> Change {
        
        loadingState.removeActivity()
        return .loading(loadingState)
    }
    
    mutating func loadMovie(fetchedMovie: MovieDetail) -> Change{
        movie = fetchedMovie
        return .initialize
    }
}