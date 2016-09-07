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
    static let flatGreen = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1)
}

extension UIColor{
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat){
        self.init (red: red/255, green: green/255, blue: blue/255, alpha:1)
    }
    
    convenience init(rgb: Int, alpha: CGFloat) {
        let r = CGFloat((rgb & 0xFF0000) >> 16)/255
        let g = CGFloat((rgb & 0xFF00) >> 8)/255
        let b = CGFloat(rgb & 0xFF)/255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    convenience init(rgb: Int) {
        self.init(rgb:rgb, alpha:1.0)
    }
    
    convenience init(rgbString: String){
        let colors = rgbString.characters.split{$0 == ","}.map(String.init).map{CGFloat(Int($0)!)}
        print(colors)
        self.init(red: colors[0], green: colors[1], blue: colors[2])
    }
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


