
import Foundation
import Firebase
import Alamofire

class MovieSearchViewModel{
    struct State {
        
        var loadingState = LoadingState()
        var movies: [Movie] = []
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    private let network = MovieSearchNetwork()
    
    private var slug: String?
    private var searchPage: Int = 1
    
    func search(searchFor searchText: String){
        let change = state.addActivity()
        emit(change)
        
        var fetchedMovies: [Movie] = []
        
        slug = searchText
        searchPage = 1
        
        network.searchWithPage(slug!, page: searchPage){[weak self] (response,results) in
            guard let strongSelf = self else{
                return
            }
            
            fetchedMovies = results.map{ (r) -> Movie in
                let name = r["Title"]!
                let year = r["Year"]!
                let imdbID = r["imdbID"]!
                let poster = r["Poster"]!
                return Movie(name: name, year: year, imdbID: imdbID, poster: poster)
            }
            
            strongSelf.emit(strongSelf.state.reloadMovies(fetchedMovies))
            strongSelf.emit(strongSelf.state.removeActivity())
        }
    }

    func loadMore(){
        let change = state.addActivity()
        emit(change)
        
        var fetchedMovies: [Movie] = []
        
        searchPage += 1
        
        network.searchWithPage(slug!, page: searchPage){[weak self] (response,results) in
            guard let strongSelf = self else{
                return
            }
            
            fetchedMovies = results.map{ (r) -> Movie in
                let name = r["Title"]!
                let year = r["Year"]!
                let imdbID = r["imdbID"]!
                let poster = r["Poster"]!
                return Movie(name: name, year: year, imdbID: imdbID, poster: poster)
            }
            
            strongSelf.emit(strongSelf.state.appendMovies(fetchedMovies))
            strongSelf.emit(strongSelf.state.removeActivity())
        }
    }

    
    func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}



extension MovieSearchViewModel.State {
    
    enum Change {
        case none
        case movies(CollectionChange)
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
    
    mutating func reloadMovies(movies: [Movie]) -> Change {
        self.movies.removeAll()
        self.movies = movies
        return .movies(.reload)
    }
    
    mutating func appendMovies(movies: [Movie]) -> Change {
        self.movies.appendContentsOf(movies)
        return .movies(.reload)
    }
    
    mutating func appendMovie(movie: Movie) -> Change {
        
        movies.append(movie)
        return .movies(.insertion(movies.count - 1))
    }
    
    mutating func removeMovieAtIndex(index: Int) -> Change {
        
        guard index >= 0 && index < movies.count else {
            return .none
        }
        movies.removeAtIndex(index)
        return .movies(.deletion(index))
    }
}