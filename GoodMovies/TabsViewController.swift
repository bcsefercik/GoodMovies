//
//  TabsViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 16/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit
import Firebase

class TabsViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
     
        tabBar.translucent = true
        tabBar.barTintColor = Color.clouds
        tabBar.tintColor = Color.midnightBlue
    }    
}
 