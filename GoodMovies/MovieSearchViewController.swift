import UIKit
import Kingfisher

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
        static let loadingCellReuseID = "movieLoadingCell"
        static let allLoadedReuseID = "allLoadedCell"
    }

    private let model = MovieSearchViewModel()
    private var presentation = MoviesPresentation()
    private let router = MovieSearchRouter()
    
    var loading: LoadingOverlay?
    
    var searchText: String?
    
    lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, self.navigationController!.navigationBar.bounds.width, 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color.clouds
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
        searchBar.placeholder = "Search movie..."
        searchBar.inputView?.tintColor = Color.midnightBlue
        searchBar.showsCancelButton = false
        searchBar.translucent = true
        searchBar.tintColor = Color.clouds
        searchBar.delegate = self
        searchBar.sizeToFit()
        
        self.navigationItem.titleView = searchBar
        navigationItem.title = nil
        
        model.search(searchFor: "network")
        
        loading = LoadingOverlay()
        self.applyState(model.state)
        
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
    }
    
    func applyState(state: MovieSearchViewModel.State){
        presentation.update(withState: state)
        
        self.tableView.reloadData()
    }
    
    func applyStateChange(change: MovieSearchViewModel.State.Change){
        switch change {
        case .movies(let change):
            
            presentation.update(withState: model.state)
            
            tableView.setContentOffset(CGPoint.init(x: 0, y: -(navigationController?.view.frame.height)!) , animated: false)
            switch change {
            case .reload:
                tableView.reloadData()
                loading?.hideOverlayView()
                
            default:
                break
            }
            
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
            
            loading?.hideOverlayView()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text!
        model.search(searchFor: searchText!)
        loading!.showOverlay(self.navigationController?.view, text: "Searching...")
        
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
        loading?.hideOverlayView()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return presentation.movies.count+1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let lastElement = presentation.movies.count
        if indexPath.row != lastElement{
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
            
            cell.backgroundColor = Color.clouds
            
            return cell
        }else{
            
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
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
 
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let lastElement = presentation.movies.count
        if indexPath.row != lastElement{
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
        router.goToMovie(presentation.movies[indexPath.row].imdbID, sender: self.navigationController!)
    }
}