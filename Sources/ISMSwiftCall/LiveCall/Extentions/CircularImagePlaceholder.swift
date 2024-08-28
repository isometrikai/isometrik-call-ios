//
//  File.swift
//  
//
//  Created by Ajay Thakur on 27/08/24.
//

import Foundation
import UIKit

class CircularImagePlaceholder{
    
  static  func createCircularInitialsPlaceholder(name: String, size: CGSize) -> UIImage {
      var placeholderSize : CGSize
      if size.width == 0 || size.height == 0 {
          placeholderSize = CGSize(width: 100, height: 100)
      }else{
          
          placeholderSize = size
      }
        let initials = getInitials(from: name)
        let label = UILabel()
        label.frame.size = placeholderSize
        label.text = initials
        label.textAlignment = .center
        label.backgroundColor = randomColor() // Use random color
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: placeholderSize.width / 2)
        label.layer.cornerRadius = placeholderSize.width / 2
        label.layer.masksToBounds = true
        
        UIGraphicsBeginImageContextWithOptions(placeholderSize, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func getInitials(from name: String) -> String {
        let words = name.split(separator: " ")
        let initials = words.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined()
    }
    
    static func randomColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(256)) / 255.0
        let green = CGFloat(arc4random_uniform(256)) / 255.0
        let blue = CGFloat(arc4random_uniform(256)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}
