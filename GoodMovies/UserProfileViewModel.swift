import Foundation
import UIKit

class UserProfileViewModel{
    struct State {
        
        var loadingState = LoadingState()
        var willWatch: [Movie] = []
        var didWatch: [Movie] = []
        var currentType = MovieStatus.willWatch
        var userInfo: User?
    }

    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    private let usertransaction = UserTransaction()
    
    func loadUserMovies(userID: String){
        usertransaction.fetchUserInfo(userID){ [weak self] (user,response) in
            //TODO: error
            
            guard let strongSelf = self, profileUser = user else { return }
            
            strongSelf.emit(strongSelf.state.addActivity())
            strongSelf.emit(strongSelf.state.loadUserInfo(profileUser))
            
            strongSelf.loadUserMovies(profileUser)
            
            strongSelf.emit(strongSelf.state.removeActivity())
        }
    }
    
    func loadUserMovies(user: User){
        self.emit(self.state.addActivity())
        
        self.usertransaction.fetchUserMovies(user.uid, type: self.state.currentType){ response,movies in
            
            if response == .success {
                self.emit(self.state.reloadMovies(movies, type: self.state.currentType))
            } else {
            //TODO: error
            }
        }
        self.emit(self.state.removeActivity())
    }
    
    
    
    
    func emit(change: State.Change){
        stateChangeHandler?(change)
    }
    
    func switchType(){
        if state.currentType == .didWatch {
            state.setCurrentType(.willWatch)
        } else {
            state.setCurrentType(.didWatch)
        }
        
        self.loadUserMovies(state.userInfo!)
    }
}

extension UserProfileViewModel.State {
    
    enum Change {
        case none
        case movies(CollectionChange, MovieStatus)
        case loading(LoadingState)
        case loadUserInfo(User)
    }
    mutating func setUser(info: User){
        userInfo = info
    }
    
    mutating func addActivity() -> Change {
        
        loadingState.addActivity()
        return .loading(loadingState)
    }
    
    mutating func loadUserInfo(user: User) -> Change {
        setUser(user)
        return .loadUserInfo(user)
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

    mutating func setCurrentType(newType: MovieStatus){
        currentType = newType
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