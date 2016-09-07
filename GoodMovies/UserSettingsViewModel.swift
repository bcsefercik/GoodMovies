//
//  UserSettingsViewModel.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 07/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import Foundation

class UserSettingsViewModel{
    struct State {
        var loadingState = LoadingState()
        var user: User?
        
        mutating func setUser(withUser: User){
            self.user = withUser
        }
    }
}