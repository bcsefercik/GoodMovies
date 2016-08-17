//
//  MovieSearchViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 17/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit
import Firebase




class MovieSearchViewController: UITableViewController, UISearchBarDelegate {

    private let model = MovieSearchViewModel()
    
    var movies = [Array<Movie>](){
        didSet{
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet{
            movies.removeAll()
            print(searchText!)
        }
    }
    
    
    lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, self.navigationController!.navigationBar.bounds.width-20 , 20))
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "Search movie..."
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.sizeToFit()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:searchBar)
        navigationItem.title = nil
        
        searchText = "run"


        
        //        self.clearsSelectionOnViewWillAppear = false
        //        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
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

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("movieSearchCell", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
