//
//  MovieUserTableViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 18/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

class MovieUserTableViewController: UITableViewController {

    var segments: UISegmentedControl = {
        let items = ["😎", "🤔"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        segments.tintColor = Color.clouds
        segments.sizeToFit()
        segments.setWidth(52.0, forSegmentAtIndex: 0)
        segments.setWidth(52.0, forSegmentAtIndex: 1)
        self.navigationItem.titleView = segments
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
}
