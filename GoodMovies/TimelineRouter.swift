import Foundation
import UIKit

class TimelineRouter : Router{
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func goToMovie(imdbID: String, sender: UINavigationController){
        let nextViewController = storyboard.instantiateViewControllerWithIdentifier("movieInfo") as! MovieInfoTableViewController
        nextViewController.imdbID = imdbID
        sender.pushViewController(nextViewController, animated: true)
    }
}