import UIKit
import Foundation


public class LoadingOverlay{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    private var textLabel = UILabel()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIView!, text: String) {
        
        overlayView = UIView(frame: CGRect(x: view.frame.midX-65, y: view.frame.midY-65, width: 130, height: 130))
        overlayView.layer.cornerRadius = 26
        
        textLabel = UILabel(frame: CGRect(x: 15, y: 72, width: 100, height: 50))
        textLabel.textAlignment = .Center
        textLabel.textColor = UIColor.whiteColor()
        textLabel.font = UIFont(name: "HelveticaNeue-Light", size: 26)
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.text = text
        overlayView.addSubview(textLabel)

        overlayView.backgroundColor = Color.midnightBlue.colorWithAlphaComponent(0.78)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.center = overlayView.center
        activityIndicator.frame = CGRect(x: 39, y: 26, width: 52, height: 52)
        overlayView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        view.addSubview(overlayView)
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}