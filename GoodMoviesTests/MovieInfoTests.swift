//
//  MovieInfoTests.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 08/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import XCTest
@testable import GoodMovies

class MovieInfoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOperations(){
        var state = MovieInfoViewModel.State()
        
        let m1 = MovieDetail(name: "asd", year: "2222", imdbID: "ttbbttt", poster: "https://firebasestorage.googleapis.com/v0/b/mymovies-e0a6f.appspot.com/o/nopicture-male.jpg?alt=media&token=a61d114d-af36-4be8-aff6-8347e5ba63b4", releaseDate: "12 Aug 2000", duration: "120 min", genre: "Horror", director: "BCS", writer: "BCS", actors: "BCS", plot: "BCS", rating: "12", language: "Turkish", country: "Turkey", awards: "Won 26 Oscars", status: .willWatch)
        
        state.loadMovie(m1)
        XCTAssertTrue(state.movie == m1)
        
        state.updateStatus(.didWatch)
        XCTAssertTrue(state.movieStatus == .didWatch)
    }
    
    func testLoading() {
        
        var state = MovieInfoViewModel.State()
        
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
