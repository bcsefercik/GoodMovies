//
//  UserSettingsViewModel.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 07/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import Foundation
import UIKit

class UserSettingsViewModel{
    struct State {
        var loadingState = LoadingState()
        var user: User?
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    private let usertransaction = UserTransaction()
    
    func initialize(){
        usertransaction.fetchUserInfo(UserConstants.currentUserID){ u,response in
            if response == .success {
                self.emit(self.state.setUser(u!))
            } else {
                self.emit(.message("Something went wrong.", .error))
            }
            
        }
    }
    
    func uploadProfilePicture(imageView: UIImageView, completion: ((DBResponse) -> Void)?){
        self.emit(self.state.addActivity())
        usertransaction.uploadProfilePicture(imageView){ response,url in
            if response == .success{
                var u = self.state.user!
                u.changePicture(url)
                self.emit(.message("Your profile picture is changed succesfully!", PopupMessageType.successful))
                self.emit(self.state.setUser(u))
            } else {
                
                completion?(.fail("Couldn't changed the picture."))
            }
            self.emit(self.state.removeActivity())
        }
    }
    
    func setColor(color: UIColor, type: String){
        self.emit(self.state.addActivity())
        let (r,g,b,_) = color.components
        let colorString = "\(String(Int(r))),\(String(Int(g))),\(String(Int(b)))"
        usertransaction.setColor(colorString, type: type){
            self.emit(self.state.removeActivity())
            self.emit(.message("Color is changed succesfully!", PopupMessageType.successful))
            self.emit(self.state.removeActivity())
        }
    }
    
    func logout(completion: (() -> Void)?){
        self.emit(self.state.addActivity())
        usertransaction.logout(){ reponse in
            self.emit(self.state.removeActivity())
            if reponse == .success {
                completion?()
            } else {
                self.emit(.message("Something went wrong!", PopupMessageType.error))
            }
            
        }
    }
    
    func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}

extension UserSettingsViewModel.State{
    enum Change {
        case user
        case message(String,PopupMessageType)
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
    
    mutating func setUser(withUser: User) ->Change{
        user = withUser
        return .user
    }
}