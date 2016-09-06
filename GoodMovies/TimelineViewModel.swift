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
    
    func initialLoad(){
        self.emit(self.state.addActivity())
        loadEntries(){
            self.emit(self.state.removeActivity())
        }
    }
    
    func loadEntries(completion: () -> Void){
        usertransaction.loadTimeline(){ response,entries in
            self.emit(self.state.reloadEntries(entries))
            completion()
        }
    }
}


extension TimelineViewModel.State{
    enum Change {
        case entries(CollectionChange)
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
    
    mutating func reloadEntries(entries: [TimelineEntry]) -> Change {
        self.entries.removeAll()
        self.entries = entries
        return .entries(.reload)
    }
}