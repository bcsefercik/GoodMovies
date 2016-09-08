//
//  UserSettingsViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 07/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

private struct UserSettingsPresentation{
    var userInfo: User?
    
    mutating func update(withState state: UserSettingsViewModel.State){
        userInfo = state.user
    }
}

class UserSettingsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private struct Const{
        static let standardReuseIdentifier = "userSettingsCell"
        static let headerReuseIdentifier = "userSettingsHeaderCell"
    }
    
    private var model = UserSettingsViewModel()
    private var presentation = UserSettingsPresentation()
    private let router = UserSettingsRouter()
    
    private let picker = BCSColorPicker.picker
    
    let sections = ["Profile",
                    "Account",
                    "Other"]
    let rows = [["Picture","Background color", "Text color"],
               ["Password", "Email", "Name"],
               ["Logout"]]

    private var profileImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        model.initialize()
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Color.clouds
        
        navigationItem.title = "Settings"
        
        picker.colorPalette = FlatColors.allColors
        picker.numberOfColorsInARow = 5
        picker.height = 390
    }
    
    func applyState(state: UserSettingsViewModel.State){
        presentation.update(withState: state)
        self.tableView.reloadData()
    }
    
    func applyStateChange(change: UserSettingsViewModel.State.Change){
        
        switch change {
        case .user:
            presentation.update(withState: model.state)
            tableView.reloadData()
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
            
        }
    }

    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        model.uploadProfilePicture(profileImageView, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func chooseBackground(){
        picker.showColorPicker(self.navigationController!, animated: true){ color,index in
            if color != nil {
                self.model.setColor(FlatColors.allColors[index], type: "bgColor")
            }
        }
    }
    
    func chooseForeground(){
        picker.showColorPicker(self.navigationController!, animated: true){ color,index in
            self.model.setColor(color!, type: "fgColor")
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows[section].count
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier(Const.headerReuseIdentifier) as! SettingsStandardViewCell
        headerCell.titleLabel.text = self.sections[section]
        return headerCell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Const.standardReuseIdentifier, forIndexPath: indexPath) as! SettingsStandardViewCell
        cell.titleLabel.text = self.rows[indexPath.section][indexPath.row]
        
        switch indexPath.section {
        case 0:
            cell.accessoryType = .None
        default:
            break
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                handleSelectProfileImageView()
            case 1:
                chooseBackground()
            case 2:
                chooseForeground()
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                router.goToChangePassword(self.navigationController!)
            case 1:
                router.goToChangeEmail(self.navigationController!, email: self.presentation.userInfo!.email)
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                model.logout(){
                    self.router.goToLogin()
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
