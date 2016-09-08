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
        static let emptyCellReuseID = "timelineEmptyCell"
    }
    
    var secCount = 1
    var infoRowCount = 0
    
    var userID = UserConstants.currentUserID
    
    private var model = TimelineViewModel()
    private var presentation = TimelinePresentation()
    private let router = TimelineRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.applyState(model.state)
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        model.initialLoad()
        
        tableView.tableFooterView = UIView()
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        imageView.image = UIImage(named: "whitelogo")
        imageView.contentMode = .ScaleAspectFit
        
        self.navigationItem.title = nil
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.titleView = imageView
        
    }
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        model.loadEntries(){
            refreshControl.endRefreshing()
        }
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentation.entries.count > 0 ? presentation.entries.count : (model.state.loadingState.isActive ? 0 : 1)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if presentation.entries.count > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.cellReuseID, forIndexPath: indexPath) as! TimelineCell
            
            let entry = presentation.entries[indexPath.row]
            cell.movieTitle.text = entry.movieName
            cell.movieYear.text = entry.movieYear
            cell.movieDate.text = "\(NSDate(timeIntervalSince1970: entry.date).getElapsedInterval()) ago"
            cell.moviePoster.kf_setImageWithURL(entry.moviePoster)
            cell.username.text = entry.username
            cell.movieType.text = (entry.type == .willWatch ? "will watch" : "watched")
            
            cell.profileImage.kf_setImageWithURL(entry.userPicture)
            cell.profileImage.layer.masksToBounds = true
            cell.profileImage.layer.cornerRadius = 10
            
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            cell.backgroundColor = Color.clouds
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.emptyCellReuseID, forIndexPath: indexPath)
            return cell
        }
    }
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    
    override func viewWillDisappear(animated: Bool) {
        LoadingOverlay.shared.hideOverlayView()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        router.goToMovie(presentation.entries[indexPath.row].imdbID, sender: self.navigationController!)
    }
    

}
