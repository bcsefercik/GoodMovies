//
//  TimelineTests.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 08/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import XCTest
@testable import GoodMovies

class TimelineTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOperations(){
        
        var state = TimelineViewModel.State()
        
        let e1 = TimelineEntry(movieName: "Runner", movieYear: "2010", imdbID: "tt9988", moviePoster: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4", type: "willWatch", date: 0.0, username: "nc", userPicture: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4", userID: "123wgefbdjns")
        let e2 = TimelineEntry(movieName: "Blade Runner", movieYear: "2010", imdbID: "tt9988", moviePoster: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4", type: "willWatch", date: 0.0, username: "nc", userPicture: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4", userID: "123wgefbdjns")
        
        let reloadChange = state.reloadEntries([e1, e2])
        XCTAssertTrue(reloadChange == .entries(.reload) )
        XCTAssertTrue(state.entries == [e1, e2])
    }
    
    func testLoading() {
        
        var state = TimelineViewModel.State()
        
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
