//
//  USChangePasswordViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 08/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

class USChangeEmailViewController: UIViewController {
    
    private var model = UserSettingsViewModel()
    
    @IBOutlet weak var email: UITextField!
    var oldEmail: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        model.initialize()
        
        email.text = oldEmail
        
        navigationItem.title = "Change Email"
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
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
    
    @IBAction func changeEmail(sender: UIButton) {
        model.changeEmail(email.text!){ new in
            if new != nil {
                self.email.text = new
                self.oldEmail = new
            }
        }
    }
    
}
