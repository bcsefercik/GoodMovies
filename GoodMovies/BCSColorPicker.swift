//
//  BCSColorPicker.swift
//
//  Created by Bugra Sefercik on 01/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//


import UIKit

class BCSColorPicker: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UIGestureRecognizerDelegate {
    
    @IBInspectable
    var numberOfColorsInARow: Int = 6
    @IBInspectable
    var backgroundColor = UIColor.clearColor()
    @IBInspectable
    var width:CGFloat = 260
    @IBInspectable
    var height:CGFloat = 260
    @IBInspectable
    var radius:CGFloat = 13
    @IBInspectable
    var border:CGFloat = 3
    @IBInspectable
    var borderColor:UIColor = UIColor.whiteColor()
    
    var colorPalette: [UIColor] = [UIColor.redColor(), UIColor.cyanColor(), UIColor.blueColor(), UIColor.grayColor(), UIColor.darkGrayColor(), UIColor.blackColor(), UIColor.brownColor(), UIColor.greenColor(), UIColor.whiteColor(), UIColor.orangeColor(), UIColor.purpleColor(), UIColor.yellowColor(), UIColor.magentaColor()]
    
    private var overlayView = UIView()
    private var colorSelectionAction: ((UIColor?, Int) -> Void)?
    private lazy var collectionView = UICollectionView()
    private lazy var cancelButton = UIButton()
    
    private var senderController: UIViewController?
    private var senderTransitionStyle = true
    private var senderPresentationContext = true
    private var animation = true
    
    private lazy var flowLayout:UICollectionViewFlowLayout = {
        var flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsetsZero
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        return flow
    }()
    
    class var picker: BCSColorPicker {
        struct Static {
            static let instance: BCSColorPicker = BCSColorPicker()
        }
        return Static.instance
    }

    func showColorPicker(controller: UIViewController, animated: Bool, selection: ((UIColor?, Int) -> Void)){
        colorSelectionAction = selection
        senderController = controller
        senderTransitionStyle = controller.providesPresentationContextTransitionStyle
        senderPresentationContext = controller.definesPresentationContext
        animation = animated
        controller.providesPresentationContextTransitionStyle = true
        controller.definesPresentationContext = true
        self.modalPresentationStyle = .OverCurrentContext
        controller.presentViewController(self, animated: animation, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = {
            let cv = UICollectionView(frame: CGRect(x: self.view.frame.midX - (self.width*0.5), y: self.view.frame.midY - (self.height*0.5), width: self.width, height: self.height-32), collectionViewLayout: self.flowLayout)
            cv.backgroundColor = UIColor.clearColor()
            cv.delegate = self
            cv.dataSource = self
            cv.bounces = true
            cv.layer.borderWidth = self.border
            cv.layer.cornerRadius = self.radius
            cv.layer.borderColor = self.borderColor.CGColor
            cv.backgroundColor = self.borderColor
            cv.registerClass(BCSColorPickerCell.self, forCellWithReuseIdentifier: "colorPickerCell")
            return cv
        }()
        
        cancelButton  = {
            let button = UIButton(type: .System)
            button.setTitle("Cancel", forState: .Normal)
            button.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
            button.titleLabel?.font = UIFont.systemFontOfSize(13)
            button.layer.cornerRadius = self.radius/2
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(BCSColorPicker.touchedCancel(_:)), forControlEvents: .TouchUpInside)
            return button
        }()
        
        self.view.backgroundColor = UIColor.clearColor()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blurEffectView)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.cancelButton)
        
        cancelButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        cancelButton.topAnchor.constraintEqualToAnchor(collectionView.bottomAnchor, constant: 6).active = true
        cancelButton.heightAnchor.constraintEqualToConstant(26).active = true
        cancelButton.widthAnchor.constraintEqualToConstant(78).active = true
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        let width:CGFloat = self.width/CGFloat(self.numberOfColorsInARow)
        return CGSizeMake(width, width)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.flowLayout.invalidateLayout()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return colorPalette.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorPickerCell", forIndexPath: indexPath) as! BCSColorPickerCell
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = backgroundColor.CGColor
        cell.backgroundColor = colorPalette[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.dismissPicker(self.colorPalette[indexPath.row],index: indexPath.row)
    }
    
    @objc private func touchedCancel(sender: UIButton!){
        self.dismissPicker(nil, index: -1)
    }
    
    private func dismissPicker(color: UIColor?, index: Int){
        self.senderController?.providesPresentationContextTransitionStyle = self.senderTransitionStyle
        self.senderController?.definesPresentationContext = self.senderPresentationContext
        self.dismissViewControllerAnimated(animation){
            self.colorSelectionAction!(color, index)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController!) -> UIModalPresentationStyle {
        return .None
    }

}

class BCSColorPickerCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

