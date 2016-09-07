//
//  MovieInfoTableViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 22/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit
import Kingfisher

struct MovieDetailPresentation{
    var movie: MovieDetail?
    var movieStatus: MovieStatus?
    
    mutating func update(withState state: MovieInfoViewModel.State){
        movie = state.movie
        movieStatus = state.movieStatus
    }
}


class MovieInfoTableViewController: UITableViewController {
    private struct Const {
        static let titleReuseID = "movieTitleCellID"
        static let posterReuseID = "moviePosterCellID"
        static let creditReuseID = "movieCreditCellID"
        static let plotReuseID = "moviePlotCellID"
        static let willIcon = Constants.willIcon
        static let didIcon = Constants.didIcon
    }
    
    var imdbID: String?
    var rowCount = 0
    var secCount = 0
    
    private let model = MovieInfoViewModel()
    private var presentation = MovieDetailPresentation()
    
    var loading: LoadingOverlay?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.backgroundColor = Color.clouds
        tableView.allowsSelection = false
        
        LoadingOverlay.shared.showOverlay(self.navigationController?.view, text: "Getting movie...")
        
        model.fetchMovie(self.imdbID!)
        
        self.applyState(model.state)
        
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        tableView.tableFooterView = UIView()
        
        setupButtons()
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    func applyState(state: MovieInfoViewModel.State){
        presentation.update(withState: state)
        
        
        
        self.tableView.reloadData()
    }

    func applyStateChange(change: MovieInfoViewModel.State.Change){
        switch change {
        case .movie(let status):
            
            presentation.update(withState: model.state)
            
            switch status {
            case .didWatch:
                tableView.reloadData()
            case .willWatch:
                tableView.reloadData()
            case .none:
                tableView.reloadData()
            }
            
            LoadingOverlay.shared.hideOverlayView()
        case .loading(let loadingState):
            if loadingState.needsUpdate {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = loadingState.isActive
            }
            
        case .none:
            let alert = UIAlertController(
                title: "",
                message: "No movies found.",
                preferredStyle: .Alert
            )
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            
            LoadingOverlay.shared.hideOverlayView()
        case .initialize:
            presentation.update(withState: model.state)
            secCount = 1
            rowCount = 10
            self.tableView.reloadData()
            LoadingOverlay.shared.hideOverlayView()
        case .reloadButtons:
            presentation.update(withState: model.state)
            self.setupButtons()
            LoadingOverlay.shared.hideOverlayView()
        }
        
    }

    
    func setupButtons(){
        let willButton = UIButton(type: .System)
        willButton.layer.cornerRadius = 5
        willButton.layer.borderWidth = 1
        willButton.layer.borderColor = Color.clouds.CGColor
        willButton.setTitle(Const.willIcon, forState: .Normal)
        willButton.frame = CGRectMake(0, 0, 65, 30)
        willButton.translatesAutoresizingMaskIntoConstraints = false
        willButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        willButton.addTarget(self, action: #selector(handleAddToList), forControlEvents: .TouchUpInside)
        
        
        let didButton = UIButton(type: .System)
        didButton.layer.cornerRadius = 5
        didButton.layer.borderWidth = 1
        didButton.layer.borderColor = Color.clouds.CGColor
        didButton.setTitle(Const.didIcon, forState: .Normal)
        didButton.frame = CGRectMake(0, 0, 65, 30)
        didButton.translatesAutoresizingMaskIntoConstraints = false
        didButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        didButton.addTarget(self, action: #selector(handleAddToList), forControlEvents: .TouchUpInside)
        
        switch presentation.movieStatus! {
        case .willWatch:
            willButton.backgroundColor = Color.flatGreen
        case .didWatch:
            didButton.backgroundColor = Color.flatGreen
        default:
            break
        }
        
        let item1 = UIBarButtonItem()
        item1.customView = willButton
        let item2 = UIBarButtonItem()
        item2.customView = didButton
        
        self.navigationItem.setRightBarButtonItems([item2,item1], animated: true)
        
        self.navigationController?.navigationBar.tintColor = Color.clouds
    }
    
    func handleAddToList(sender: UIButton){
        if sender.currentTitle == Const.didIcon{
            model.addToList(MovieStatus.didWatch)
        } else {
            model.addToList(MovieStatus.willWatch)
        }
    }
    
    func posterTapped(sender: UITapGestureRecognizer) {
        let newImageView = UIImageView()
        newImageView.kf_setImageWithURL(presentation.movie?.posterBig)
        newImageView.frame = self.view.frame
        let handsfreeTap = UITapGestureRecognizer(target: self, action: #selector(MovieInfoTableViewController.dismissFullscreenImage(_:)))
        newImageView.addGestureRecognizer(handsfreeTap)
        newImageView.backgroundColor = .blackColor()
        newImageView.contentMode = .ScaleAspectFit
        newImageView.userInteractionEnabled = true
        LoadingOverlay.shared.showOverlay(self.navigationController!.view, text: "Loading image...")
        self.navigationController?.view.addSubview(newImageView)
    }

    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        LoadingOverlay.shared.hideOverlayView()
        sender.view?.removeFromSuperview()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return secCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rowCount
    }

    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        LoadingOverlay.shared.hideOverlayView()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.titleReuseID) as! MovieInfoTitleCell
            cell.movieTitle.text = presentation.movie?.name
            cell.movieYear.text = "(" + (presentation.movie?.year)! + ")"
            cell.movieGenre.text = (presentation.movie?.genre)! + " | " + (presentation.movie?.duration)!
            cell.movieTitle.tintColor = Color.clouds
            cell.movieYear.tintColor = Color.wetAsphalt
            cell.movieGenre.tintColor = Color.wetAsphalt
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.posterReuseID) as! MovieInfoPosterCell
            cell.moviePoster.kf_setImageWithURL(presentation.movie?.poster)
            let handsfreeTap = UITapGestureRecognizer(target: self, action: #selector(MovieInfoTableViewController.posterTapped(_:)))
            cell.moviePoster.userInteractionEnabled = true
            cell.moviePoster.addGestureRecognizer(handsfreeTap)
            cell.movieRating.text = presentation.movie?.rating
            cell.layoutMargins = UIEdgeInsetsZero
            cell.backgroundColor = Color.clouds
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.creditReuseID) as! MovieInfoCreditCell
            cell.creditType.text = "Actors"
            cell.creditInfo.text = presentation.movie?.actors
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.creditReuseID) as! MovieInfoCreditCell
            cell.creditType.text = "Director"
            cell.creditInfo.text = presentation.movie?.director
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.creditReuseID) as! MovieInfoCreditCell
            cell.creditType.text = "Writer"
            cell.creditInfo.text = presentation.movie?.writer
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        case 5:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.creditReuseID) as! MovieInfoCreditCell
            cell.creditType.text = "Release Date"
            cell.creditInfo.text = presentation.movie?.releaseDate
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        case 6:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.creditReuseID) as! MovieInfoCreditCell
            cell.creditType.text = "Language"
            cell.creditInfo.text = presentation.movie?.language
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        case 7:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.creditReuseID) as! MovieInfoCreditCell
            cell.creditType.text = "Country"
            cell.creditInfo.text = presentation.movie?.country
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        case 8:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.creditReuseID) as! MovieInfoCreditCell
            cell.creditType.text = "Awards"
            cell.creditInfo.text = presentation.movie?.awards
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        case 9:
            let cell = tableView.dequeueReusableCellWithIdentifier(Const.plotReuseID) as! MovieInfoPlotCell
            cell.moviePlot.text = presentation.movie?.plot
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
