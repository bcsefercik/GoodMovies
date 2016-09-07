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
        static let standardGoReuseIdentifier = "userSettingsGoCell"
        static let headerReuseIdentifier = "userSettingsHeaderCell"
    }
    
    private var model = UserSettingsViewModel()
    private let router = UserSettingsRouter()
    
    let sections = ["Profile",
                    "Account",
                    "Other"]
    let rows = [["Picture","Background color", "Text color"],
               ["Password", "Name", "Email"],
               ["Logout"]]

    private var profileImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.tableFooterView = UIView()
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
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
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
        var cell = tableView.dequeueReusableCellWithIdentifier(Const.standardGoReuseIdentifier, forIndexPath: indexPath) as! SettingsStandardViewCell
        cell.titleLabel.text = self.rows[indexPath.section][indexPath.row]
        

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                handleSelectProfileImageView()
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
