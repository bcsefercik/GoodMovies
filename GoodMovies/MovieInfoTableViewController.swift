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
        static let posterReuseID = "moviePosterCellID"
        static let creditReuseID = "movieCreditCellID"
        static let plotReuseID = "moviePlotCellID"
    }
    
    var imdbID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.backgroundColor = Color.clouds
        
        setupButtons()
        
        print(imdbID)
    }
    
    func setupButtons(){
        let willButton = UIButton(type: .System)
        willButton.layer.cornerRadius = 5
        willButton.layer.borderWidth = 1
        willButton.layer.borderColor = Color.clouds.CGColor
        willButton.setTitle("🤔", forState: .Normal)
        willButton.frame = CGRectMake(0, 0, 65, 30)
        willButton.translatesAutoresizingMaskIntoConstraints = false
        willButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        let item1 = UIBarButtonItem()
        item1.customView = willButton
        
        
        let didButton = UIButton(type: .System)
        didButton.layer.cornerRadius = 5
        didButton.layer.borderWidth = 1
        didButton.layer.borderColor = Color.clouds.CGColor
        didButton.setTitle("😎", forState: .Normal)
        didButton.frame = CGRectMake(0, 0, 65, 30)
        didButton.translatesAutoresizingMaskIntoConstraints = false
        didButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        didButton.addTarget(self, action: #selector(handleDidWatch), forControlEvents: .TouchUpInside)
        let item2 = UIBarButtonItem()
        item2.customView = didButton
        
        self.navigationItem.setRightBarButtonItems([item1,item2], animated: true)
        
        self.navigationController?.navigationBar.tintColor = Color.clouds
    }
    
    func handleDidWatch(){
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.titleReuseID) as! MovieInfoTitleCell
            
            cell.movieTitle.text = "The Movie Title"
            cell.layoutMargins = UIEdgeInsetsZero
            cell.backgroundColor = Color.clouds
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.posterReuseID) as! MovieInfoPosterCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.backgroundColor = Color.clouds
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.creditReuseID) as! MovieInfoCreditCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.backgroundColor = Color.clouds
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.plotReuseID) as! MovieInfoPlotCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.backgroundColor = Color.clouds
            return cell
        default:
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
