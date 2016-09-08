import Foundation
import UIKit

class LoginRegisterRouter : Router{
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func goToLogin(){
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        UIView.transitionWithView(appDelegate.window!, duration: 0.38, options: .TransitionCrossDissolve, animations: {
            let oldState: Bool = UIView.areAnimationsEnabled()
            UIView.setAnimationsEnabled(false)
            appDelegate.window?.rootViewController = loginVC
            UIView.setAnimationsEnabled(oldState)
            }, completion: nil)
    }
    
    func goToRegister(){
        let registerVC = storyboard.instantiateViewControllerWithIdentifier("RegisterVC") as! RegisterViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        UIView.transitionWithView(appDelegate.window!, duration: 0.38, options: .TransitionCrossDissolve, animations: {
            let oldState: Bool = UIView.areAnimationsEnabled()
            UIView.setAnimationsEnabled(false)
            appDelegate.window?.rootViewController = registerVC
            UIView.setAnimationsEnabled(oldState)
            }, completion: nil)
    }
    
    func goToMain(){
        
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("TabBarVC") as! TabsViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        UIView.transitionWithView(appDelegate.window!, duration: 0.38, options: .TransitionCrossDissolve, animations: {
            let oldState: Bool = UIView.areAnimationsEnabled()
            UIView.setAnimationsEnabled(false)
            appDelegate.window?.rootViewController = loginVC
            UIView.setAnimationsEnabled(oldState)
            }, completion: nil)
    }
}