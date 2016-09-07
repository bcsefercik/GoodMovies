import Foundation
import UIKit

class UserSettingsRouter : Router{
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func goToMovie(imdbID: String, sender: UINavigationController){
        let nextViewController = storyboard.instantiateViewControllerWithIdentifier("movieInfo") as! MovieInfoTableViewController
        nextViewController.imdbID = imdbID
        sender.pushViewController(nextViewController, animated: true)
    }
    
    func goToLogin(){
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        UIView.transitionWithView(appDelegate.window!, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            let oldState: Bool = UIView.areAnimationsEnabled()
            UIView.setAnimationsEnabled(false)
            appDelegate.window?.rootViewController = loginVC
            UIView.setAnimationsEnabled(oldState)
            }, completion: nil)
    }
}