//
//  MovieSearchViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 17/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit
import Firebase


struct MoviesPresentation{
    var movies: [MoviePresentation] = []
    
    mutating func update(withState state: MovieSearchViewModel.State){
        movies = state.movies.map{(movie) -> MoviePresentation in
            return MoviePresentation(imdbID: movie.imdbID, title: movie.name, year: "\(movie.year)", poster: movie.poster)
            
        }
    }
}

class MovieSearchViewController: UITableViewController, UISearchBarDelegate {
    
    private struct Const {
         static let cellReuseID = "movieSearchCell"
    }

    private let model = MovieSearchViewModel()
    private var presentation = MoviesPresentation()
    weak var loading: LoadingView!
    
    var searchText: String?
    
    
    lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, self.navigationController!.navigationBar.bounds.width, 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "Search movie..."
        searchBar.inputView?.tintColor = Color.midnightBlue
        searchBar.showsCancelButton = false
        searchBar.translucent = true
        searchBar.tintColor = Color.clouds
        searchBar.delegate = self
        searchBar.sizeToFit()
        
        self.navigationItem.titleView = searchBar
        navigationItem.title = nil
        
        
        self.applyState(model.state)
        
        model.search(searchFor: "sky")
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        //        self.clearsSelectionOnViewWillAppear = false
        //        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
        loading = addLoading()
        loading.text.text = "Searching..."
    }
    
    
    func applyState(state: MovieSearchViewModel.State){
        presentation.update(withState: state)
        self.tableView.reloadData()
    }
    
    
    
    func applyStateChange(change: MovieSearchViewModel.State.Change){
        switch change {
        case .movies(let change):
            
            presentation.update(withState: model.state)
            
            switch change {
            case .reload:
                tableView.reloadData()
                loading.hide()
            default:
                break
            }
            
        case .loading(let loadingState):
            if loadingState.needsUpdate {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = loadingState.isActive
            }
            
        case .none:
            break
        }    }
    
    
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text!
        model.search(searchFor: searchText!)
        loading.showIn(true)
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        loading.hide()
        searchBar.setShowsCancelButton(false, animated: true)
    }
      // MARK: - Table view data source



    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return presentation.movies.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var templateCell = tableView.dequeueReusableCellWithIdentifier(Const.cellReuseID)
        
        if templateCell == nil {
            templateCell = UITableViewCell(style: .Subtitle, reuseIdentifier: Const.cellReuseID)
        }
        
        guard let cell = templateCell else {
            fatalError()
        }
        
        let moviePresentation = presentation.movies[indexPath.row]
        if let movieCell = cell as? MovieSearchViewCell{
            movieCell.moviePresentation = moviePresentation
        }
        
        
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let willWatch = UITableViewRowAction(style: .Normal, title: "🤔") { (action, indexPath) in
            // delete item at indexPath
        }
        willWatch.backgroundColor = Color.wetAsphalt
        
        let watched = UITableViewRowAction(style: .Normal, title: "😎") { (action, indexPath) in
            // share item at indexPath
        }
        
        watched.backgroundColor = Color.clouds
        
        return [willWatch, watched]
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            print("delete")
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let lastElement = presentation.movies.count-1
        if indexPath.row >= (lastElement-1) {
            model.loadMore()
        }
    }
    

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

extension UITableViewController{
    override func addLoading() -> LoadingView{
        let lv = UINib(nibName: "LoadingView", bundle:
            NSBundle(forClass:self.dynamicType)).instantiateWithOwner(nil,
                                                                      options: nil)[0] as! LoadingView
        
        self.view.addSubview(lv)
        
        lv.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: lv, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: lv, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        self.view.addConstraint(verticalConstraint)
        
        let views = ["lv": lv]
        
        let widthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[lv(130)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(widthConstraints)
        
        let heightConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[lv(130)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(heightConstraints)
        lv.layer.cornerRadius = 13
        lv.hide()
        return lv
    }
}
