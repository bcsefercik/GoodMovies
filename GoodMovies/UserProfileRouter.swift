import Foundation
import UIKit

class UserProfileRouter : Router{
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func goToMovie(imdbID: String, sender: UINavigationController){
        let nextViewController = storyboard.instantiateViewControllerWithIdentifier("movieInfo") as! MovieInfoTableViewController
        nextViewController.imdbID = imdbID
        sender.pushViewController(nextViewController, animated: true)
    }
    func goToSettings(sender: UINavigationController){
        let nextViewController = storyboard.instantiateViewControllerWithIdentifier("userSettings")
        sender.pushViewController(nextViewController, animated: true)
    }
}