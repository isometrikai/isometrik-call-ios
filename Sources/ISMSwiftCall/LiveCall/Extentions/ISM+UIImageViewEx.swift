//
//  ISM+UIImageViewEx.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 13/03/24.
//

import Foundation
import Kingfisher
import UIKit

extension UIImageView : AppearanceProvider{
    
    func setImage(urlString: String?,placeholderImage : UIImage? = nil){
        
        var image : UIImage
        
        if let placeholderImage{
            image = placeholderImage
        }else{
            image = appearance.images.profileAvatar
        }
        guard let urlString ,let url = URL(string: urlString) else{
            self.image = image
            return
        }
       
        self.kf.setImage(with:url,placeholder: image)
    }
    
}

