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


extension NSDate {
    
    func getElapsedInterval() -> String {
        
        var interval = NSCalendar.currentCalendar().components(.Year, fromDate: self, toDate: NSDate(), options: []).year
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "year" :
                "\(interval)" + " " + "years"
        }
        
        interval = NSCalendar.currentCalendar().components(.Month, fromDate: self, toDate: NSDate(), options: []).month
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "month" :
                "\(interval)" + " " + "months"
        }
        
        interval = NSCalendar.currentCalendar().components(.Day, fromDate: self, toDate: NSDate(), options: []).day
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "day" :
                "\(interval)" + " " + "days"
        }
        
        interval = NSCalendar.currentCalendar().components(.Hour, fromDate: self, toDate: NSDate(), options: []).hour
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "hour" :
                "\(interval)" + " " + "hours"
        }
        
        interval = NSCalendar.currentCalendar().components(.Minute, fromDate: self, toDate: NSDate(), options: []).minute
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "minute" :
                "\(interval)" + " " + "minutes"
        }
        
        return "a moment ago"
    }
}