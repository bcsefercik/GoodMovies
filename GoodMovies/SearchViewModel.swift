
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
                        fetchedUsers.append(UserSimple(name: user.1["name"]!, username: user.1["username"]!, uid: user.0.stringByReplacingOccurrencesOfString(strongSelf.usertransaction.cUserID, withString: UserConstants.currentUserID), picture: user.1["profilePicture"]!))
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
                self?.emit(.message("Couldn't find the movie.", .error))
                completion(.error(DBResponseError.empty), nil)
                return
            }
        }
        
    }

    func loadMore(){
        if(self.searchPage>0){
            
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
                default:
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
    
    func addToList(index: Int, newStatus: MovieStatus){
        let md = state.movies[index]
        self.emit(self.state.addActivity())
        
        let movie = Movie(name: md.name , year: md.year, imdbID: md.imdbID, poster: md.poster.absoluteString, status: newStatus)
        usertransaction.addMovie(movie){ response in
            self.emit(self.state.removeActivity())
            self.emit(.message("\(movie.name) is added to your list.", .successful))
        }
    }

    
    func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}



extension SearchViewModel.State {
    
    enum Change: Equatable {
        case none
        case movies(CollectionChange)
        case loading(LoadingState)
        case message(String,PopupMessageType)
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
    
    
    mutating func switchType(){
        userSearch = !userSearch
    }
    
    func reload() -> Change {
        return .movies(.reload)
    }
}

func == (lhs: SearchViewModel.State.Change, rhs: SearchViewModel.State.Change) -> Bool {
    switch lhs {
    case .movies(let l):
        switch rhs {
        case .movies(let r):
            return l == r
        default:
            return false
        }
    default:
        return false
    }
}