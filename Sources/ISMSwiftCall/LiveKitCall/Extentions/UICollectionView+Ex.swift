//
//  File.swift
//  
//
//  Created by Ajay Thakur on 30/07/24.
//

import Foundation
import UIKit

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UICollectionView {
    func cellForItem(at safeIndexPath: IndexPath) -> UICollectionViewCell? {
        guard safeIndexPath.section < numberOfSections,
              safeIndexPath.item < numberOfItems(inSection: safeIndexPath.section) else {
            return nil
        }
        return cellForItem(at: safeIndexPath)
    }
}
