//
//  UserProfileViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 24/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit
import Firebase

struct UserMoviesPresentation{
    var willWatch: [MoviePresentation] = []
    var didWatch: [MoviePresentation] = []
    var currentType = MovieStatus.willWatch
    
    mutating func update(withState state: UserProfileViewModel.State, type: MovieStatus){
        switch type {
        case .didWatch:
            didWatch = state.didWatch.map{(movie) -> MoviePresentation in
                return MoviePresentation(imdbID: movie.imdbID, title: movie.name, year: "\(movie.year)", poster: movie.poster)
            }
        case .willWatch:
            willWatch = state.willWatch.map{(movie) -> MoviePresentation in
                return MoviePresentation(imdbID: movie.imdbID, title: movie.name, year: "\(movie.year)", poster: movie.poster)
            }
        case .none:
            didWatch = state.didWatch.map{(movie) -> MoviePresentation in
                return MoviePresentation(imdbID: movie.imdbID, title: movie.name, year: "\(movie.year)", poster: movie.poster)
            }
            willWatch = state.willWatch.map{(movie) -> MoviePresentation in
                return MoviePresentation(imdbID: movie.imdbID, title: movie.name, year: "\(movie.year)", poster: movie.poster)
            }
        }
        currentType = state.currentType
    }
    var movieCount: Int{
        get{
            switch currentType {
            case .didWatch:
                return didWatch.count
            default:
                return willWatch.count
            }
        }
    }
}

class UserProfileViewController: UITableViewController {
    
    struct Const{
        static let infoReuseID = "userProfileInfoCell"
        static let pickerReuseID = "userProfilePickerCell"
        static let movieReuseID = "userProfileMovieCell"
    }
    
    var secCount = 1
    var infoRowCount = 0
    
    var userID = UserConstants.currentUserID
    
    private let model = UserProfileViewModel()
    private var presentation = UserMoviesPresentation()
    private let router = UserProfileRouter()
    private var userInfo: User?
    var loading: LoadingOverlay?
    
    
    let database = DatabaseAdapter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loading = LoadingOverlay()
        self.applyState(model.state)
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        loading?.showOverlay(navigationController?.view, text: "Loading...")
        
        //model.initialize(userID)
        
        database.fetch((FIRAuth.auth()?.currentUser?.uid)!, path: "users/"){ (_,i) in
        }
    }
    
    
    func applyState(state: UserProfileViewModel.State){
        presentation.update(withState: state, type: .willWatch)
        
        self.tableView.reloadData()
    }
    
    func applyStateChange(change: UserProfileViewModel.State.Change){
        switch change {
        case .movies(let change, let type):
            
            presentation.update(withState: model.state, type: type)
            
            
            switch change {
            case .reload:
                tableView.reloadData()
                loading?.hideOverlayView()
                
            case .deletion(let index):
                tableView.deleteRowsAtIndexPaths(
                    [NSIndexPath(forRow: index+2, inSection: 0)],
                    withRowAnimation: .Automatic
                )
            default:
                tableView.setContentOffset(CGPoint.init(x: 0, y: -60) , animated: false)
                break
            }
            
        case .loading(let loadingState):
            if loadingState.needsUpdate {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = loadingState.isActive
            }
        case .change(let type):
            break
        case .loadUserInfo:
            userInfo = model.state.userInfo
            navigationController?.title = userInfo?.username
            infoRowCount = 1
            tableView.reloadData()
        case .none:
            tableView.setContentOffset(CGPoint.init(x: 0, y: -60) , animated: false)
            let alert = UIAlertController(
                title: "",
                message: "No movies found.",
                preferredStyle: .Alert
            )
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            
            loading?.hideOverlayView()
        }
    }

    
    

    @IBAction func segmentedChanged(sender: UISegmentedControl) {
        model.switchType()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.infoReuseID) as! UserProfileInfoViewCell
            cell.nameLabel.text = userInfo?.name
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
        return presentation.movieCount+infoRowCount
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
