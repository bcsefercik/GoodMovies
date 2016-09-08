//
//  USChangePasswordViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 08/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

class USChangePasswordViewController: UIViewController {

    private var model = UserSettingsViewModel()
    
    @IBOutlet weak var oldP: UITextField!
    @IBOutlet weak var newP: UITextField!
    @IBOutlet weak var newPA: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        model.initialize()
        
        navigationItem.title = "Change Password"
    }
    func applyStateChange(change: UserSettingsViewModel.State.Change){
        
        switch change {
        case .message(let msg, let type):
            PopupMessage.shared.showMessage(self.navigationController?.view, text: msg, type:  type)
        case .loading(let loadingState):
            if loadingState.needsUpdate {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = loadingState.isActive
            }
            if loadingState.isActive {
                LoadingOverlay.shared.showOverlay(self.navigationController!.view, text: "Loading...")
            } else {
                LoadingOverlay.shared.hideOverlayView()
            }
         
        default:
            break
        }
    }

    @IBAction func changePassword(sender: UIButton) {
        model.changePassword(oldP.text, newPassword: newP.text, newPasswordAgain: newPA.text)
    }

}
