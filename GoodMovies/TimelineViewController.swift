//
//  TimelineViewController.swift
//  GoodMovies
//
//  Created by Buğra Can Sefercik on 06/09/16.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

struct TimelinePresentation{
    var entries: [TimelineEntry] = []
    
    mutating func update(withState state: TimelineViewModel.State){
        entries.removeAll()
        entries = state.entries
    }
}

class TimelineViewController: UITableViewController {
    private struct Const{
        static let cellReuseID = "timelineCell"
    }
    
    var secCount = 1
    var infoRowCount = 0
    
    var userID = UserConstants.currentUserID
    
    private var model = TimelineViewModel()
    private var presentation = TimelinePresentation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.applyState(model.state)
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        model.initialLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    func applyState(state: TimelineViewModel.State){
        presentation.update(withState: state)
        self.tableView.reloadData()
    }

    func applyStateChange(change: TimelineViewModel.State.Change){
        
        presentation.update(withState: model.state)
        switch change {
        case .entries(let type):
            switch type {
            case .reload:
                presentation.update(withState: model.state)
                tableView.reloadData()
            default:
                tableView.reloadData()
            }
        case .loading(let loadingState):
            if loadingState.needsUpdate {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = loadingState.isActive
            }
            if loadingState.isActive {
                LoadingOverlay.shared.showOverlay(self.navigationController?.view, text: "Loading...")
            } else {
                LoadingOverlay.shared.hideOverlayView()
            }

        }
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return presentation.entries.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Const.cellReuseID, forIndexPath: indexPath) as! TimelineCell
        
        cell.layoutMargins = UIEdgeInsetsZero
        
        let entry = presentation.entries[indexPath.row]
        cell.movieTitle.text = entry.movieName
        cell.movieYear.text = entry.movieYear
        cell.movieDate.text = "\(NSDate(timeIntervalSince1970: entry.date).getElapsedInterval()) ago"
        cell.moviePoster.kf_setImageWithURL(entry.moviePoster)
        cell.username.text = entry.username
        
        cell.profileImage.kf_setImageWithURL(entry.userPicture)
        cell.profileImage.layer.masksToBounds = true
        cell.profileImage.layer.cornerRadius = 10
        
        return cell
    }
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }


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
