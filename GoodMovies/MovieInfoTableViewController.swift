//
//  MovieInfoTableViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 22/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

class MovieInfoTableViewController: UITableViewController {
    
    private struct Const {
        static let titleReuseID = "movieTitleCellID"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.titleReuseID) as! MovieInfoTitleCell
            
            cell.movieTitle.text = "Moviiii"
            cell.layoutMargins = UIEdgeInsetsZero
            cell.backgroundColor = Color.clouds
            return cell
        } else{
            let templateCell = tableView.dequeueReusableCellWithIdentifier(Const.titleReuseID)
            return templateCell!
        }
    
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
