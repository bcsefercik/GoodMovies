import Foundation
import UIKit

struct Color{
    static let midnightBlue = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1)
    static let wetAsphalt = UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1)
    static let clouds = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
    static let flatGreen = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1)
    static let flatRed = UIColor(rgb: 0xD91E18)
}

extension UIColor{
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat){
        self.init (red: red/255, green: green/255, blue: blue/255, alpha:1)
    }
    
    convenience init(rgb: Int, alpha: CGFloat) {
        let r = CGFloat((rgb & 0xFF0000) >> 16)/255
        let g = CGFloat((rgb & 0xFF00) >> 8)/255
        let b = CGFloat(rgb & 0xFF)/255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    convenience init(rgb: Int) {
        self.init(rgb:rgb, alpha:1.0)
    }
    
    convenience init(rgbString: String){
        let colors = rgbString.characters.split{$0 == ","}.map(String.init).map{CGFloat(Int($0)!)}
        self.init(red: colors[0], green: colors[1], blue: colors[2])
    }
    
    var coreImageColor: CoreImage.CIColor {
        return CoreImage.CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let color = coreImageColor
        return (color.red*255, color.green*255, color.blue*255, color.alpha)
    }
}