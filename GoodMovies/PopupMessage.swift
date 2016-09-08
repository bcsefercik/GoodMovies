import UIKit
import Foundation


public class PopupMessage{
    
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    private var textLabel = UILabel()
    
    class var shared: PopupMessage {
        struct Static {
            static let instance: PopupMessage = PopupMessage()
        }
        return Static.instance
    }
    
    func showMessage(view: UIView!, text: String, type: PopupMessageType) {
        
        overlayView = UIView(frame: CGRect(x: view.frame.midX-130, y: view.frame.midY-50, width: 260, height: 100))
        overlayView.layer.cornerRadius = 26
        
        textLabel = UILabel(frame: CGRect(x: 10, y: 5, width: 240, height: 80))
        textLabel.textAlignment = .Center
        textLabel.textColor = UIColor.whiteColor()
        textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 26)
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.text = text
        
        
        switch type {
        case .successful:
            overlayView.backgroundColor = Color.flatGreen
        case .error:
            overlayView.backgroundColor = Color.flatRed
        default:
            overlayView.backgroundColor = UIColor.blackColor()
        }
        overlayView.backgroundColor = overlayView.backgroundColor!.colorWithAlphaComponent(0.9)
        
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = 26
        blurEffectView.clipsToBounds = true
        blurEffectView.frame = overlayView.bounds
        blurEffectView.backgroundColor = UIColor.clearColor()
        blurEffectView.translatesAutoresizingMaskIntoConstraints = true
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        //overlayView.addSubview(blurEffectView)
        overlayView.addSubview(textLabel)
        overlayView.alpha = 0
        view.addSubview(overlayView)
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.overlayView.alpha = 1.0
        }){ a in
            UIView.animateWithDuration(0.2, delay: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.overlayView.alpha = 0
            }){ a in
                self.overlayView.removeFromSuperview()
            }
        }
    }
    
}


enum PopupMessageType{
    case successful
    case error
    case none
}