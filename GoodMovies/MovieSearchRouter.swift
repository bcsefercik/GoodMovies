import Foundation
import UIKit

class MovieSearchRouter : Router{
    var storyboard = UIStoryboard(name: "Main", bundle: nil)

    func goToMovie(imdbID: String, sender: UINavigationController){
        let nextViewController = storyboard.instantiateViewControllerWithIdentifier("movieInfo")
        //nextViewController.imdbID = imdbID
        sender.pushViewController(nextViewController, animated: true)
    }
}