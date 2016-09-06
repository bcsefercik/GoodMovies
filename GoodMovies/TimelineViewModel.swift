//
//  TimelineViewModel.swift
//  GoodMovies
//
//  Created by Buğra Can Sefercik on 06/09/16.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import Foundation

class TimelineViewModel{
    struct State {
        var loadingState = LoadingState()
        var entries: [TimelineEntry] = []
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?

    private let usertransaction = UserTransaction()
    
    func emit(change: State.Change){
        stateChangeHandler?(change)
    }
    
    func loadEntries(){
        usertransaction.loadTimeline(){ response,entries in
            self.emit(self.state.reloadEntries(entries))
        }
    }
}


extension TimelineViewModel.State{
    enum Change {
        case entries(CollectionChange)
        case loading(LoadingState)
    }
    
    mutating func reloadEntries(entries: [TimelineEntry]) -> Change {
        self.entries.removeAll()
        self.entries = entries
        return .entries(.reload)
    }
}