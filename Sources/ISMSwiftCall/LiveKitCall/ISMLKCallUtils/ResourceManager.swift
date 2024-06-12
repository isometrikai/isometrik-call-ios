//
//  File.swift
//  
//
//  Created by Ajay Thakur on 12/06/24.
//

import Foundation
import UIKit
public class ResourceManager {
    public static func loadImage(named imageName: String) -> UIImage? {
        let bundle = Bundle.main
        return UIImage(named: imageName, in: bundle, compatibleWith: nil)
    }
}
