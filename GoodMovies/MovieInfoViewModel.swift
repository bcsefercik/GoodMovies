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
    
    
    
    func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}



extension MovieInfoViewModel.State {
    
    enum Change {
        case none
        case willWatch
        case didWatch
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
}