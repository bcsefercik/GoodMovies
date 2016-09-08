//
//  UserProfileTests.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 08/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import XCTest
@testable import GoodMovies

class UserProfileTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOperations(){
        var state = UserProfileViewModel.State()
        
        let user = User(uid: "bcsbcs131313", username: "bcs", name: "Buğra", willWatchCount: 13, didWatchCount: 13, followerCount: 13, followingCount: 13, picture: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4")
        state.setUser(user)
        XCTAssertFalse(state.userInfo == nil)
        XCTAssertTrue(state.userInfo!.uid == user.uid)
        
        
        let newUser = User(uid: "barbara", username: "bcs", name: "Buğra", willWatchCount: 13, didWatchCount: 13, followerCount: 13, followingCount: 13, picture: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4")
        
        state.loadUserInfo(newUser)
        XCTAssertFalse(state.userInfo == nil)
        XCTAssertTrue(state.userInfo!.uid == newUser.uid)
        
        let m1 = Movie(name: "Runner", year: "2000", imdbID: "tt9999", poster: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4")
        let m2 = Movie(name: "Interstellar", year: "2014", imdbID: "tt9955599", poster: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4")
        state.reloadMovies([m1,m2], type: .willWatch)
        XCTAssertTrue(state.willWatch == [m1,m2])
        state.removeMovieAtIndex(0, type: .willWatch)
        XCTAssertTrue(state.willWatch == [m2])
        
        
        state.reloadMovies([m1,m2], type: .didWatch)
        XCTAssertTrue(state.didWatch == [m1,m2])
        state.removeMovieAtIndex(0, type: .didWatch)
        XCTAssertTrue(state.didWatch == [m2])
        
        XCTAssertTrue(state.removeMovieAtIndex(3, type: .didWatch) == .none)
        XCTAssertTrue(state.removeMovieAtIndex(3, type: .willWatch) == .none)
        
        XCTAssertTrue(state.movieCount == 2)
        
        state.emptyResult()
        XCTAssertTrue(state.didWatch.count == 0)
        XCTAssertTrue(state.willWatch.count == 0)
        XCTAssertTrue(state.movieCount == 0)
        
        state.setCurrentType(.none)
        XCTAssertTrue(state.currentType == .none)
        
        
    }

    
    func testLoading() {
        
        var state = UserProfileViewModel.State()
        
        state.addActivity()
        XCTAssertTrue(state.loadingState.activityCount == 1)
        XCTAssertTrue(state.loadingState.needsUpdate)
        
        state.addActivity()
        XCTAssertTrue(state.loadingState.activityCount == 2)
        XCTAssertFalse(state.loadingState.needsUpdate)
        
        state.removeActivity()
        XCTAssertTrue(state.loadingState.activityCount == 1)
        XCTAssertFalse(state.loadingState.needsUpdate)
        
        state.removeActivity()
        XCTAssertTrue(state.loadingState.activityCount == 0)
        XCTAssertTrue(state.loadingState.needsUpdate)
    }
    
}
