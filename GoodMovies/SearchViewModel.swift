
import Foundation

class SearchViewModel{
    struct State {
        
        var loadingState = LoadingState()
        var movies: [Movie] = []
        var users: [UserSimple] = []
        
        var userSearch = false
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    private let network = SearchNetwork()
    private let usertransaction = UserTransaction()
    
    private var slug: String?
    private var searchPage: Int = 0
    private var totalMovies = 0
    
    func switchType(){
        state.switchType()
        self.search(searchFor: self.slug!){
            self.emit(self.state.reload())
        }
    }
    
    func search(searchFor searchText: String){
        search(searchFor: searchText, completion: nil)
    }
    
    func search(searchFor searchText: String, completion: (() -> Void)?){
        let change = state.addActivity()
        emit(change)
        slug = searchText
        searchPage = 1
        
        if state.userSearch {
            usertransaction.searchUser(searchText){ [weak self] response,result in
                guard let strongSelf = self else{
                    return
                }
                if response == .success {
                    var fetchedUsers: [UserSimple] = []
                    
                    for user in result! {
                        fetchedUsers.append(UserSimple(name: user.1["name"]!, username: user.1["username"]!, uid: user.0, picture: "https://media.licdn.com/mpr/mpr/shrinknp_400_400/p/3/005/048/24d/228b7e9.jpg"))
                    }
                    strongSelf.emit(strongSelf.state.reloadUsers(fetchedUsers))
                    strongSelf.emit(strongSelf.state.removeActivity())
                } else {
                    strongSelf.emit(strongSelf.state.emptyResult())
                    strongSelf.emit(strongSelf.state.removeActivity())
                    strongSelf.searchPage = 0
                }
                return
            }
        } else {
            searchMovie(searchFor: searchText){ [weak self] response,result in
                guard let strongSelf = self else{
                    return
                }
                
                if response == .success {
                    strongSelf.emit(strongSelf.state.reloadMovies(result!))
                    strongSelf.emit(strongSelf.state.removeActivity())
                } else {
                    strongSelf.emit(strongSelf.state.emptyResult())
                    strongSelf.emit(strongSelf.state.removeActivity())
                    strongSelf.searchPage = 0
                }
                return
            }
        }
    }
    
    private func searchMovie(searchFor searchText: String, completion: (DBResponse, [Movie]?) -> Void){
        
        var fetchedMovies: [Movie] = []
        
        
        
        network.searchWithPage(slug!, page: searchPage){[weak self] (response,results, totalResults) in
            guard let strongSelf = self else{
                return
            }
            
            switch response{
            case .success:
                
                fetchedMovies = results.map{ (r) -> Movie in
                    let name = r["Title"]!
                    let year = r["Year"]!
                    let imdbID = r["imdbID"]!
                    let poster = r["Poster"]!
                    return Movie(name: name, year: year, imdbID: imdbID, poster: poster)
                }
                
                strongSelf.totalMovies = totalResults
                completion(.success, fetchedMovies)
                return
            default:
                completion(.error(DBResponseError.empty), nil)
                return
            }
        }
        
    }

    func loadMore(){
        if(self.searchPage>0){
            let change = state.addActivity()
            emit(change)
            
            var fetchedMovies: [Movie] = []
            
            searchPage += 1
            
            network.searchWithPage(slug!, page: searchPage){[weak self] (response,results, totalResults) in
                guard let strongSelf = self else{
                    return
                }
                
                switch response{
                case .success:
                
                    fetchedMovies = results.map{ (r) -> Movie in
                        let name = r["Title"]!
                        let year = r["Year"]!
                        let imdbID = r["imdbID"]!
                        let poster = r["Poster"]!
                        return Movie(name: name, year: year, imdbID: imdbID, poster: poster)
                    }
                    
                    
                    strongSelf.emit(strongSelf.state.appendMovies(fetchedMovies))
                    strongSelf.emit(strongSelf.state.removeActivity())
                default:
                    strongSelf.emit(strongSelf.state.removeActivity())
                    strongSelf.searchPage = 0
                }

            }
        }
    }

    func fullyLoaded()->Bool{
        if state.userSearch {
            return true
        } else {
            return totalMovies <= state.movies.count
        }
    }
    
    func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}



extension SearchViewModel.State {
    
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
    mutating func emptyResult() -> Change {
        self.movies.removeAll()
        return .none
    }
    
    mutating func reloadMovies(movies: [Movie]) -> Change {
        self.movies.removeAll()
        self.movies = movies
        return .movies(.reload)
    }
    
    mutating func reloadUsers(users: [UserSimple]) -> Change {
        self.users.removeAll()
        self.users = users
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
    
    mutating func switchType(){
        userSearch = !userSearch
    }
    
    func reload() -> Change {
        return .movies(.reload)
    }
}