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
    
    func changePassword(oldPassword: String?, newPassword: String?, newPasswordAgain: String?) {
        self.emit(self.state.addActivity())
        if oldPassword == "" || oldPassword == nil || newPassword == "" || newPassword == nil || newPasswordAgain == "" || newPasswordAgain == nil {
            self.emit(.message("Please fill all fields.", .error))
            self.emit(self.state.removeActivity())
        } else if newPassword != newPasswordAgain{
            self.emit(.message("Your new passwords must be same.", .error))
            self.emit(self.state.removeActivity())
        } else {
            usertransaction.changePassword(state.user!.username, oldPassword: oldPassword!, newPassword: newPassword!, newPasswordAgain: newPasswordAgain!){ response in
                self.emit(self.state.removeActivity())
                switch response {
                case .success:
                    self.emit(.message("Your password hass been changed successfully.", .successful))
                case .fail(let msg):
                    self.emit(.message(msg, .error))
                default:
                    break
                }
            }
        }
        
    }
    
    func changeEmail(email: String, completion:((String?) -> Void)?){
        self.emit(self.state.addActivity())
        if isValidEmail(email){
            usertransaction.changeEmail(email){ response in
                self.emit(self.state.removeActivity())
                switch response {
                case .success:
                    self.emit(.message("Your email has been changed successfully.", .successful))
                    completion?(email)
                default:
                    self.emit(.message("Something went wrong. :(", .error))
                }
            }
        } else {
            self.emit(self.state.removeActivity())
            self.emit(.message("Please enter a valid email.", .error))
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(testStr)
        return result
    }
    
    func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}

extension UserSettingsViewModel.State{
    enum Change : Equatable {
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
func ==(lhs: UserSettingsViewModel.State.Change, rhs: UserSettingsViewModel.State.Change) -> Bool{
    switch lhs {
    case .user:
        switch rhs {
        case .user:
            return true
        default:
            return false
        }
    default:
        return false
    }
}