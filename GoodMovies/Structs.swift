//
//  Helpers.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 12/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit
import Foundation

struct Color{
    static let midnightBlue = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1)
    static let wetAsphalt = UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1)
    static let clouds = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
}

enum CollectionChange {
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


