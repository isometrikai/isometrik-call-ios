//
//  ISM+UIImageViewEx.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 13/03/24.
//

import Foundation
import UIKit


extension UIImageView : AppearanceProvider{
    private static let imageCache = NSCache<NSString, UIImage>()
    
    func setImage(urlString: String?, placeholderImage: UIImage? = nil) {
        var image: UIImage
        
        if let placeholderImage {
            image = placeholderImage
        } else {
            image = appearance.images.profileAvatar
        }
        
        guard let urlString, let url = URL(string: urlString) else {
            self.image = image
            return
        }
        
        if let cachedImage = UIImageView.imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        self.image = image
        
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: url), let downloadedImage = UIImage(data: data) {
                UIImageView.imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                
                DispatchQueue.main.async {
                    self.image = downloadedImage
                }
            }
        }
    }
}
