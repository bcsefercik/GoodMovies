import UIKit

class LoadingView: UIView {
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var text: UILabel!

    
    
    func setLabel(label: String){
        text.text = label
    }
    
    func hide(){
        self.hidden = true
    }
    
    func show(){
        self.hidden = false
    }
    func showIn(animated: Bool){
        show()
    }
    func hide(animated: Bool){
        hide()
    }
}

