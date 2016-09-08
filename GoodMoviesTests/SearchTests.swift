//
//  MovieInfoTests.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 08/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import XCTest
@testable import GoodMovies

class SearchTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOperations(){
        var state = SearchViewModel.State()
        
        let m1 = Movie(name: "Runner", year: "2000", imdbID: "tt9999", poster: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4")
        let m2 = Movie(name: "Interstellar", year: "2014", imdbID: "tt9955599", poster: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4")
        state.reloadMovies([m1,m2])
        XCTAssertTrue(state.movies == [m1,m2])
        
        state.emptyResult()
        XCTAssertTrue(state.movies.count == 0)
        
        state.appendMovie(m1)
        XCTAssertTrue(state.movies == [m1])
        
        state.appendMovies([m1,m2])
        XCTAssertTrue(state.movies == [m1,m1,m2])
        
        let u1 = UserSimple(name: "Buğra", username: "bcs", uid: "1313", picture: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4")
        let u2 = UserSimple(name: "Ali", username: "al", uid: "454545", picture: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4")
        state.reloadUsers([u1,u2])
        XCTAssertTrue(state.users == [u1,u2])
        
        let b = state.userSearch
        state.switchType()
        XCTAssertFalse(b == state.userSearch)
        
        XCTAssertTrue(state.reload() == .movies(.reload))
    }
    
    func testLoading() {
        
        var state = SearchViewModel.State()
        
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
