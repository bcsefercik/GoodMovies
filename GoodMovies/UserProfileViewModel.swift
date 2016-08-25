import Foundation
import UIKit

class UserProfileViewModel{
    struct State {
        
        var loadingState = LoadingState()
        var willWatch: [Movie] = []
        var didWatch: [Movie] = []
    }

    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}

extension UserProfileViewModel.State {
    
    enum Change {
        case none
        case movies(CollectionChange, MovieStatus)
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
        self.willWatch.removeAll()
        self.didWatch.removeAll()
        return .none
    }
    
    mutating func reloadMovies(movies: [Movie], type: MovieStatus) -> Change {
        switch type {
        case .didWatch:
            self.didWatch.removeAll()
            self.didWatch = movies
            return .movies(.reload, .didWatch)
        default:
            self.willWatch.removeAll()
            self.willWatch = movies
            return .movies(.reload, .willWatch)
        }
    }
    
    mutating func removeMovieAtIndex(index: Int, type: MovieStatus) -> Change {
        switch type {
        case .didWatch:
            guard index >= 0 && index < didWatch.count else {
                return .none
            }
            didWatch.removeAtIndex(index)
        default:
            guard index >= 0 && index < willWatch.count else {
                return .none
            }
            willWatch.removeAtIndex(index)
        }
        return .movies(.deletion(index), type)
    }

    
    mutating func appendMovies(movies: [Movie], type: MovieStatus) -> Change {
        switch type {
        case .didWatch:
            self.didWatch.appendContentsOf(movies)
            return .movies(.reload, .didWatch)
        default:
            self.willWatch.appendContentsOf(movies)
            return .movies(.reload, .willWatch)
        }
    }
}