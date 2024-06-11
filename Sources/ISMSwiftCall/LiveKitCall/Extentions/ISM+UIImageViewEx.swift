//
//  ISM+UIImageViewEx.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 13/03/24.
//

import Foundation
import Kingfisher
import UIKit

extension UIImageView {
    
    func setImage(urlString: String?){
        let image = UIImage(named: "profile_avatar")
        guard let urlString ,let url = URL(string: urlString) else{
            self.image = image
            return
        }
       
        self.kf.setImage(with:url,placeholder: image)
    }
    
}
