//
//  UserProfileViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 24/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

struct UserProfilePresentation{
    var movies: [ProfileMoviePresentation] = []
    var currentType = MovieStatus.willWatch
    var profileUser: User?
    var profileStatus = UserProfileViewModel.Status.none
    
    mutating func update(withState state: UserProfileViewModel.State, type: MovieStatus){
        switch type {
        case .didWatch:
            movies = state.didWatch.map{(movie) -> ProfileMoviePresentation in
                return ProfileMoviePresentation(imdbID: movie.imdbID, title: movie.name, year: "\(movie.year)", poster: movie.poster, userDate: movie.date)
            }
        default:
            movies = state.willWatch.map{(movie) -> ProfileMoviePresentation in
                return ProfileMoviePresentation(imdbID: movie.imdbID, title: movie.name, year: "\(movie.year)", poster: movie.poster, userDate: movie.date)
            }
        }
        currentType = state.currentType
        profileStatus = state.profileStatus
    }
    
    mutating func setUser(u: User){
        profileUser = u
    }
    
    mutating func updateProfileStatus(withState state: UserProfileViewModel.State){
        profileStatus = state.profileStatus
        profileUser = state.userInfo
    }
}

class UserProfileViewController: UITableViewController, UINavigationControllerDelegate {
    
    private struct Const{
        static let infoReuseID = "userProfileInfoCell"
        static let pickerReuseID = "userProfilePickerCell"
        static let movieReuseID = "userProfileMovieCell"
    }
    
    var secCount = 1
    var infoRowCount = 0
    
    var userID = UserConstants.currentUserID
    
    private let model = UserProfileViewModel()
    private var presentation = UserProfilePresentation()
    private let router = UserProfileRouter()
    var loading: LoadingOverlay?
    
    private lazy var rightBarButton = UIButton(type: .System)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        
        self.applyState(model.state)
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        LoadingOverlay.shared.showOverlay(navigationController?.view, text: "Loading...")
        
        model.loadUserMovies(userID)
        
        navigationItem.backBarButtonItem?.tintColor = Color.clouds
        navigationController?.navigationBar.tintColor = Color.clouds
        tableView.tableFooterView = UIView()
        
        
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        model.loadUserMovies(userID)
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func isCurrentUser() -> Bool{
        return UserConstants.currentUserID == userID
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
                infoRowCount = 2
                self.navigationItem.rightBarButtonItem = nil
                self.navigationItem.rightBarButtonItems = nil
                self.setupButtons()
                presentation.update(withState: model.state, type: type)
                presentation.updateProfileStatus(withState: model.state)
                tableView.reloadData()
                LoadingOverlay.shared.hideOverlayView()
                
            case .deletion(let index):
                tableView.deleteRowsAtIndexPaths(
                    [NSIndexPath(forRow: index+2, inSection: 0)],
                    withRowAnimation: .Automatic
                )
                presentation.update(withState: model.state, type: type)
            default:
                tableView.setContentOffset(CGPoint.init(x: 0, y: -60) , animated: false)
            }
        case .message(let msg, let type):
            PopupMessage.shared.showMessage(self.navigationController?.view, text: msg, type:  type)
        case .loadButtons:
            presentation.updateProfileStatus(withState: model.state)
            setupButtons()
            tableView.reloadData()
        case .loading(let loadingState):
            if loadingState.needsUpdate {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = loadingState.isActive
            }
            if loadingState.isActive {
                
            } else {
                LoadingOverlay.shared.hideOverlayView()
            }
        case .loadUserInfo(let u):
            presentation.setUser(u)
            navigationItem.title = presentation.profileUser?.username
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
            
            LoadingOverlay.shared.hideOverlayView()
        }
        LoadingOverlay.shared.hideOverlayView()
    }

    @IBAction func segmentedChanged(sender: UISegmentedControl) {
        model.switchType()
        LoadingOverlay.shared.showOverlay(navigationController?.view, text: "Fetching movies...")
    }
    
    override func viewWillDisappear(animated: Bool) {
        LoadingOverlay.shared.hideOverlayView()
        
        self.navigationItem.rightBarButtonItem = nil
    }

    func setupButtons(){
        let item = UIBarButtonItem()
        switch presentation.profileStatus {
        case .currentUser:
            rightBarButton  = {
                let button = UIButton(type: .System)
                button.setTitle("Settings", forState: .Normal)
                button.sizeToFit()
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitleColor(Color.clouds, forState: .Normal)
                button.addTarget(self, action: #selector(handleTopButton), forControlEvents: .TouchUpInside)
                return button
            }()
        case .following:
            rightBarButton  = {
                let button = UIButton(type: .System)
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 1
                button.layer.borderColor = Color.clouds.CGColor
                button.layer.backgroundColor = Color.flatGreen.CGColor
                button.setTitle("Following", forState: .Normal)
                button.frame = CGRectMake(0, 0, 91, 30)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitleColor(Color.clouds, forState: .Normal)
                button.addTarget(self, action: #selector(handleTopButton), forControlEvents: .TouchUpInside)
                return button
            }()
        case .none:
            rightBarButton  = {
                let button = UIButton(type: .System)
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 1
                button.layer.borderColor = Color.clouds.CGColor
                button.setTitle("Follow", forState: .Normal)
                button.frame = CGRectMake(0, 0, 65, 30)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitleColor(Color.clouds, forState: .Normal)
                button.addTarget(self, action: #selector(handleTopButton), forControlEvents: .TouchUpInside)
                return button
            }()
        }
        item.customView = rightBarButton
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.setRightBarButtonItem(item, animated: true)
    }
    
    @objc private func handleTopButton(){
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        switch presentation.profileStatus {
        case .currentUser:
            router.goToSettings(self.navigationController!)
        case .following:
            LoadingOverlay.shared.showOverlay(self.navigationController!.view, text: "Unfollowing...")
            model.unfollow()
        case .none:
            LoadingOverlay.shared.showOverlay(self.navigationController!.view, text: "Following...")
            model.follow()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.infoReuseID) as! UserProfileInfoViewCell
            let bC = UIColor(rgbString: (model.state.userInfo?.bgColor)!)
            cell.backgroundColor = bC
            let tC = UIColor(rgbString: (model.state.userInfo?.fgColor)!)
            cell.nameLabel.text = presentation.profileUser?.name.capitalizedString
            cell.nameLabel.textColor = tC
            cell.moviesLabel.text = "\(model.state.movieCount)"
            cell.moviesLabel.textColor = tC
            cell.followersLabel.text = "\(presentation.profileUser!.followerCount)"
            cell.followersLabel.textColor = tC
            cell.followingLabel.text = "\(presentation.profileUser!.followingCount!)"
            cell.followingLabel.textColor = tC
            cell.smallMovies.textColor = tC
            cell.smallFollowers.textColor = tC
            cell.smallFollowings.textColor = tC
            cell.profilePicture.kf_setImageWithURL(presentation.profileUser!.picture!)
            cell.profilePicture.layer.masksToBounds = true
            cell.profilePicture.layer.cornerRadius = 60
            cell.profilePicture.layer.borderWidth = 2
            cell.profilePicture.layer.borderColor = tC.CGColor
            cell.layoutMargins = UIEdgeInsetsZero
            tableView.backgroundColor = bC
            tableView.tableFooterView?.backgroundColor = Color.clouds
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.pickerReuseID) as! UserProfilePickerCell
            cell.movieTypePicker.setTitle("\(Constants.willIcon) Will Watch", forSegmentAtIndex: 0)
            cell.movieTypePicker.setTitle("\(Constants.didIcon) Watched", forSegmentAtIndex: 1)
            cell.movieTypePicker.setTitleTextAttributes([NSForegroundColorAttributeName:Color.clouds], forState: .Selected)
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.movieReuseID) as! UserProfileMovieCell
            cell.layoutMargins = UIEdgeInsetsZero
            let mp = presentation.movies[indexPath.row-infoRowCount]
            cell.profileMoviePoster.kf_setImageWithURL(mp.poster)
            cell.profileMovieTitle.text = mp.title
            cell.profileMovieYear.text = mp.year
            return cell
            
        }
        
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return secCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentation.movies.count+infoRowCount
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > 1 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            router.goToMovie(presentation.movies[indexPath.row-infoRowCount].imdbID, sender: self.navigationController!)
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row>1 && userID == UserConstants.currentUserID {
            return .Delete
        } else {
            return .None
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        model.deleteMovie(indexPath.row-2)
    }
    
    
    // MARK: Buttons
    


    

}
