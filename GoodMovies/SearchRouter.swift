import Foundation
import UIKit

class SearchRouter : Router{
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func goToMovie(imdbID: String, sender: UINavigationController){
        let nextViewController = storyboard.instantiateViewControllerWithIdentifier("movieInfo") as! MovieInfoTableViewController
        nextViewController.imdbID = imdbID
        sender.pushViewController(nextViewController, animated: true)
    }
    
    func goToProfile(uid: String, sender: UINavigationController){
        let nextViewController = storyboard.instantiateViewControllerWithIdentifier("userProile") as! UserProfileViewController
        nextViewController.userID = uid
        sender.pushViewController(nextViewController, animated: true)
    }
}