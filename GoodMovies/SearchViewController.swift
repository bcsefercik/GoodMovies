import UIKit
import Kingfisher

struct SearchPresentation{
    var movies: [MoviePresentation] = []
    var users: [UserSimple] = []
    var userSearch = false
    
    mutating func update(withState state: SearchViewModel.State){
        movies = state.movies.map{(movie) -> MoviePresentation in
            return MoviePresentation(imdbID: movie.imdbID, title: movie.name, year: "\(movie.year)", poster: movie.poster)
        }
        users = state.users
        userSearch = state.userSearch
    }
    
    var count: Int {
        get {
            if userSearch {
                return users.count
            } else {
                return movies.count
            }
        }
    }
}

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    private struct Const {
        static let cellReuseID = "movieSearchCell"
        static let loadingCellReuseID = "movieLoadingCell"
        static let allLoadedReuseID = "allLoadedCell"
        static let userReuseID = "userSearchCell"
    }
    
    private let model = SearchViewModel()
    private var presentation = SearchPresentation()
    private let router = SearchRouter()
    private let usertransaction = UserTransaction()
    
    var loading: LoadingOverlay?
    
    var searchText: String?
    @IBOutlet weak var segments: UISegmentedControl!
    
    lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, self.navigationController!.navigationBar.bounds.width, 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color.clouds
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
        searchBar.placeholder = "Search..."
        searchBar.inputView?.tintColor = Color.midnightBlue
        searchBar.showsCancelButton = false
        searchBar.translucent = true
        searchBar.tintColor = Color.clouds
        searchBar.delegate = self
        searchBar.sizeToFit()
        
        self.navigationItem.titleView = searchBar
        navigationItem.title = nil
        
        model.search(searchFor: "bcs")
        
        self.applyState(model.state)
        
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue", size: 18.0)!, forKey: NSFontAttributeName)
        self.segments.layer.cornerRadius = 0;
        self.segments.tintColor = Color.wetAsphalt
        self.segments.layer.borderColor = self.segments.tintColor.CGColor
        self.segments.layer.borderWidth = 1.5;
        self.segments.layer.masksToBounds = true
        self.segments.setTitleTextAttributes(attr as [NSObject : AnyObject], forState: .Normal)
    }
    @IBAction func typeChanged(sender: UISegmentedControl) {
        model.switchType()
        LoadingOverlay.shared.showOverlay(self.navigationController?.view, text: "Loading...")
    }
    
    func applyState(state: SearchViewModel.State){
        presentation.update(withState: state)
        
        self.tableView.reloadData()
    }
    
    func applyStateChange(change: SearchViewModel.State.Change){
        switch change {
        case .movies(let change):
            
            presentation.update(withState: model.state)
            
            
            switch change {
            case .reload:
                tableView.reloadData()
                LoadingOverlay.shared.hideOverlayView()
                
            default:
                break
            }
            
        case .loading(let loadingState):
            if loadingState.needsUpdate {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = loadingState.isActive
            }
            
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
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text!
        model.search(searchFor: searchText!)
        tableView.setContentOffset(CGPoint.init(x: 0, y: -60) , animated: false)
        LoadingOverlay.shared.showOverlay(self.navigationController?.view, text: "Searching...")
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        LoadingOverlay.shared.hideOverlayView()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return presentation.count+1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let lastElement = presentation.count
        if indexPath.row != lastElement{
            if presentation.userSearch {
                let cell = tableView.dequeueReusableCellWithIdentifier(Const.userReuseID) as! SearchUserViewCell
                let userPresentation = presentation.users[indexPath.row]
                cell.profilePicture.kf_setImageWithURL(userPresentation.picture)
                cell.profilePicture.layer.cornerRadius = 31
                cell.profilePicture.layer.masksToBounds = true
                cell.userNameLabel.text = userPresentation.name.capitalizedString
                cell.userUsernameLabel.text = userPresentation.username
                cell.backgroundColor = Color.clouds
                cell.layoutMargins = UIEdgeInsets(top: 0, left: 78, bottom: 0, right: 0)
                return cell
            } else {
                var templateCell = tableView.dequeueReusableCellWithIdentifier(Const.cellReuseID)
                
                if templateCell == nil {
                    templateCell = UITableViewCell(style: .Subtitle, reuseIdentifier: Const.cellReuseID)
                }
                
                guard let cell = templateCell else {
                    fatalError()
                }
                
                let moviePresentation = presentation.movies[indexPath.row]
                if let movieCell = cell as? MovieSearchViewCell{
                    movieCell.movieTitle.text = moviePresentation.title
                    movieCell.movieYear.text = moviePresentation.year
                    movieCell.moviePosterView.kf_setImageWithURL(moviePresentation.poster)
                }
                cell.layoutMargins = UIEdgeInsetsZero
                cell.backgroundColor = Color.clouds
                
                return cell
            }
        } else {
            
            var templateCell: UITableViewCell?
            
            if(model.fullyLoaded()){
                templateCell = tableView.dequeueReusableCellWithIdentifier(Const.allLoadedReuseID)
            } else {
                templateCell = tableView.dequeueReusableCellWithIdentifier(Const.loadingCellReuseID)

            }
            
            guard let cell = templateCell else {
                fatalError()
            }
            
            if let loadingCell = cell as? MovieLoadingTableViewCell{
                loadingCell.indicatorSpinner.startAnimating()
            }
            
            cell.backgroundColor = Color.clouds
            
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let lastElement = presentation.movies.count
        if indexPath.row != lastElement && !presentation.userSearch{
            let willWatch = UITableViewRowAction(style: .Normal, title: "🤔") { (action, indexPath) in
                // delete item at indexPath
            }
            willWatch.backgroundColor = Color.wetAsphalt
            
            let watched = UITableViewRowAction(style: .Normal, title: "😎") { (action, indexPath) in
            }
            
            watched.backgroundColor = Color.midnightBlue
            
            return [willWatch, watched]
        }
        return []
    }

    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let lastElement = presentation.movies.count-1
        if indexPath.row == (lastElement-1) {
            model.loadMore()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if presentation.userSearch {
            router.goToProfile(presentation.users[indexPath.row].uid, sender: self.navigationController!)
        } else {
            router.goToMovie(presentation.movies[indexPath.row].imdbID, sender: self.navigationController!)
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
}