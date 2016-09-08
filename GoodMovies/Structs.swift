//
//  Helpers.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 12/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//
import Foundation

enum CollectionChange: Equatable {
    case initialize
    case insertion(Int)
    case deletion(Int)
    case reload
}

struct LoadingState {
    
    private(set) var activityCount: UInt = 0
    private(set) var needsUpdate = false
    
    var isActive: Bool {
        return activityCount > 0
    }
    
    mutating func addActivity() {
        
        needsUpdate = (activityCount == 0)
        activityCount += 1
    }
    
    mutating func removeActivity() {
        
        guard activityCount > 0 else {
            return
        }
        activityCount -= 1
        needsUpdate = (activityCount == 0)
    }
}

struct Constants {
    static let willIcon = "🤔"
    static let didIcon = "😎"
}


func == (lhs: CollectionChange, rhs: CollectionChange) -> Bool{
    switch lhs {
    case .reload:
        switch rhs {
        case .reload:
            return true
        default:
            return false
        }
    default:
        return false
    }
}