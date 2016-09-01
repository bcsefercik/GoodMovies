import UIKit

class BCSColorPicker: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UIGestureRecognizerDelegate {
    
    @IBInspectable
    var numberOfColorsInARow: Int = 6
    var colorSelectionAction: ((UIColor?, Int?) -> Void)?
    @IBInspectable
    var backgroundColor = Color.wetAsphalt
    
    var pickerPalette: [UIColor] = [UIColor.blackColor(),UIColor.blueColor(),UIColor.brownColor(),UIColor.cyanColor(),UIColor.darkGrayColor(),Color.midnightBlue,Color.clouds]
    
    
    
    private lazy var collectionView:UICollectionView = {
        let cv = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.bounces = true
        cv.registerClass(BCSColorPickerCell.self, forCellWithReuseIdentifier: "colorPickerCell")
        return cv
    }()
    
    
    private lazy var flowLayout:UICollectionViewFlowLayout = {
        var flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsetsZero
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        return flow
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.collectionView)
        collectionView.backgroundColor = backgroundColor
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        let width:CGFloat = (self.view.bounds.size.width)/6
        
        return CGSizeMake(width, width)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.flowLayout.invalidateLayout()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return pickerPalette.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorPickerCell", forIndexPath: indexPath) as! BCSColorPickerCell
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = backgroundColor.CGColor
        cell.backgroundColor = UIColor.whiteColor()
        
        cell.backgroundColor = pickerPalette[indexPath.row]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.dismissViewControllerAnimated(true){
            self.colorSelectionAction!(Color.wetAsphalt,nil)
        }
    }
}
