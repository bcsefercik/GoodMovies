import Foundation
import UIKit

class UserProfileRouter : Router{
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func goToMovie(imdbID: String, sender: UINavigationController){
        let nextViewController = storyboard.instantiateViewControllerWithIdentifier("movieInfo") as? MovieInfoTableViewController
        nextViewController?.imdbID = imdbID
        
        sender.navigationItem.rightBarButtonItem = nil
        sender.navigationItem.rightBarButtonItems = nil
        nextViewController?.navigationItem.rightBarButtonItem = nil
        nextViewController?.navigationItem.rightBarButtonItems = nil
        sender.showViewController(nextViewController!, sender: sender)
    }
    func goToSettings(sender: UINavigationController){
        let nextViewController = storyboard.instantiateViewControllerWithIdentifier("userSettings")
         sender.showViewController(nextViewController, sender: sender)
    }
}