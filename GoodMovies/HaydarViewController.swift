//
//  HaydarViewController.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 01/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

class HaydarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func haydarTouched(sender: UIButton) {
        
        let colorPickerVC = BCSColorPicker()
        colorPickerVC.colorSelectionAction = { [weak self] color,index in
            self?.selectionAction(color,index: index)
        }

        
        self.presentViewController(colorPickerVC, animated: true, completion: nil)
        //self.presentViewController(nextViewController, animated: true, completion: nil)
    }

    func selectionAction(color: UIColor?, index: Int?){
        print(color!.CGColor)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
