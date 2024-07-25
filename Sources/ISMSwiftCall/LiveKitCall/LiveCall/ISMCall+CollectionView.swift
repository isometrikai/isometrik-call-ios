//
//  File.swift
//  
//
//  Created by Ajay Thakur on 10/07/24.
//

import Foundation
import UIKit
import LiveKit

class ISMLiveCallCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update cell frames here
        for indexPath in indexPathsForVisibleItems {
            if let cell = cellForItem(at: indexPath) as? ISMLiveCallCollectionViewCell {
                let updatedFrame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.size.width, height: cell.frame.size.height)
                cell.frame = updatedFrame
                cell.videoView.frame = updatedFrame
            }
        }
    }
}

extension ISMLiveCallView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /* Implement required methods for UICollectionViewDataSource and UICollectionViewDelegateFlowLayout*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /* Return the number of items in your collection view*/
        
        if remoteParticipants.isEmpty && callType == .AudioCall{
            return 1
        }

        return remoteParticipants.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if callType != .GroupCall, let callStatus{
            if callStatus == .started{
                stopAudio()
                
            }else if callStatus == .calling || callStatus == .ringing {
                stopAudio()
                self.playAudio()
                
            }
        }
        
        
        if callType == .AudioCall{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ISMAudioCallCollectionViewCell", for: indexPath) as! ISMAudioCallCollectionViewCell
            cell.configure(withName: ISMCallManager.shared.members?.first?.memberName ??   ISMCallManager.shared.members?.first?.memberIdentifier ?? "Unknown", profileImageUrl: ISMCallManager.shared.members?.first?.memberProfileImageURL , status: self.callStatus)
            return cell
        }else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ISMLiveCallCollectionViewCell", for: indexPath) as! ISMLiveCallCollectionViewCell
            let participant = remoteParticipants[indexPath.row]
            cell.participant = participant
            if callType == .GroupCall{
                cell.setDetails(name:ISMCallManager.shared.callDetails?.meetingDescription ?? "Group Call" , status: self.callStatus ?? .calling)
            }else{
                cell.setDetails(name:ISMCallManager.shared.members?.first?.memberName ??   ISMCallManager.shared.members?.first?.memberIdentifier ?? "Unknown" , status: self.callStatus ?? .calling)
            }
            return cell
        }
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = collectionView.frame.size
        let width = screenSize.width - 2
        let height = screenSize.height - 2
        
        let numberOfItems = collectionView.numberOfItems(inSection: indexPath.section)
        switch numberOfItems {
           case 1:
               return CGSize(width: screenSize.width, height: screenSize.height)
           case 2:
            return CGSize(width: screenSize.width, height: height / 2)
           case 3:
               if indexPath.item < 2 {
                   return CGSize(width: width / 2, height: height / 2)
               } else {
                   return CGSize(width: width, height: height / 2)
               }
               
           case 4:
               return CGSize(width: width / 2, height: height / 2)
               
           case 5:
               if indexPath.item < 4 {
                   return CGSize(width: width / 2, height: height / 3)
               } else {
                   return CGSize(width: width, height: height / 3)
               }
               
           case 6:
               return CGSize(width: width / 2, height: height / 3)
               
           default:
               return CGSize(width: width / 3, height: height / 3)
           }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        maximiseTheView()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
}
