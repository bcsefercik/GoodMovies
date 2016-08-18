
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
    
    func search(searchFor searchText: String){
        let change = state.addActivity()
        stateChangeHandler?(change)
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let strongSelf = self else { return }
            var fetchedMovies: [Movie] = []
            
            
            Alamofire.request(
                .GET,
                "http://www.omdbapi.com/?",
                parameters: ["s": searchText]
                )
                .responseJSON { response in
                    guard response.result.isSuccess else {
                        print("Error while fetching tags: \(response.result.error)")  
                        return
                    }
                    
                    guard let responseJSON = response.result.value as? [String: AnyObject],
                        results = responseJSON["Search"] as? [[String: String]]
                        else {
                        print("Invalid tag information received from service")
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