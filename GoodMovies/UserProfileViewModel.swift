import Foundation
import UIKit

class UserProfileViewModel{
    struct State {
        
        var loadingState = LoadingState()
        var willWatch: [Movie] = []
        var didWatch: [Movie] = []
        var currentType = MovieStatus.willWatch
        var userInfo: User?
        var profileStatus = UserProfileViewModel.Status.none
    }

    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    private let usertransaction = UserTransaction()
    
    func loadUserMovies(userID: String){
        if userID == UserConstants.currentUserID {
            state.profileStatus = .currentUser
        }
        
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
            
            if response == .success || response == .error(.empty){
                switch self.state.profileStatus {
                case .currentUser:
                    self.emit(.loadButtons)
                    self.emit(self.state.reloadMovies(movies, type: self.state.currentType))
                default:
                    self.usertransaction.isFollowing((self.state.userInfo?.uid)!, followerID: self.usertransaction.cUserID){ _,f in
                        if f {
                            self.state.profileStatus = .following
                        } else {
                            self.state.profileStatus = .none
                        }
                        self.emit(.loadButtons)
                        self.emit(self.state.reloadMovies(movies, type: self.state.currentType))
                    }
                }
                
            } else {
            
            //TODO: error
            }
        }
        self.emit(self.state.removeActivity())
    }
    
    func unfollow(){
        usertransaction.unfollowUser(state.userInfo!){ response in
            switch response{
            case .success, .error(.empty):
                self.state.profileStatus = .none
                self.loadUserMovies(self.state.userInfo!.uid)
            default:
                //TODO: error
                break
            }
        }
    }
    
    func follow(){
        usertransaction.followUser(state.userInfo!){ response in
            switch response{
            case .success, .error(.empty):
                self.state.profileStatus = .following
                self.loadUserMovies(self.state.userInfo!.uid)
            default:
                //TODO: error
                break
            }
        }
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
    
    enum Status {
        case currentUser
        case following
        case none
    }
}

extension UserProfileViewModel.State {
    
    enum Change {
        case none
        case movies(CollectionChange, MovieStatus)
        case loading(LoadingState)
        case loadUserInfo(User)
        case loadButtons
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