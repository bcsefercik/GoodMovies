
import Foundation

class MovieSearchViewModel{
    struct State {
        
        var loadingState = LoadingState()
        var movies: [Movie] = []
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
}

extension MovieSearchViewModel.State {
    
    enum Change {
        case none
        case movies(CollectionChange)
        case loading(LoadingState)
    }
    
    mutating func addActivity() -> Change {
        
        loadingState.addActivity()
        return Change.loading(loadingState)
    }
    
    mutating func removeActivity() -> Change {
        
        loadingState.removeActivity()
        return .loading(loadingState)
    }
    
    mutating func reloadMovies(movies: [Movie]) -> Change {
        
        self.movies = movies
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