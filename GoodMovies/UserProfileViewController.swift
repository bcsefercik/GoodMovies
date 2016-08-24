//
//  UserProfileViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 24/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

class UserProfileViewController: UITableViewController {
    
    struct Const{
        static let infoReuseID = "userProfileInfoCell"
        static let pickerReuseID = "userProfilePickerCell"
        static let movieReuseID = "userProfileMovieCell"
    }
    
    var rowCount = 3
    var secCount = 1
    
    var userID: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func segmentedChanged(sender: UISegmentedControl) {
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.infoReuseID) as! UserProfileInfoViewCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.backgroundColor = UIColor.whiteColor()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.pickerReuseID) as! UserProfilePickerCell
            cell.movieTypePicker.setTitle("\(Constants.willIcon) Will Watch", forSegmentAtIndex: 0)
            cell.movieTypePicker.setTitle("\(Constants.didIcon) Watched", forSegmentAtIndex: 1)
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        default:
            let templateCell = tableView.dequeueReusableCellWithIdentifier(Const.movieReuseID) as? UserProfileMovieCell
            templateCell!.layoutMargins = UIEdgeInsetsZero
            return templateCell!
            
        }
        
        
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return secCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
