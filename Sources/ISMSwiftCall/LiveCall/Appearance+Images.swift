//
//  File.swift
//  
//
//  Created by Ajay Thakur on 12/06/24.
//

import Foundation
import UIKit

public extension Appearance {
    struct Images {
        /// A private internal function that will safely load an image from the bundle or return a circle image as backup
        /// - Parameter imageName: The required image name to load from the bundle
        /// - Returns: A UIImage that is either the correct image from the bundle or backup circular image
        private static func loadImageSafely(with imageName: String) -> UIImage {
            if let image = UIImage(named: imageName, in: .ismSwiftCall) {
                return image
            } else {
                print(
                    """
                    \(imageName) image has failed to load from the bundle please make sure it's included in your assets folder.
                    A default 'red' circle image has been added.
                    """
                )
                return UIImage.circleImage
            }
        }
        
        private static func loadSafely(systemName: String, assetsFallback: String) -> UIImage {
            if #available(iOS 13.0, *) {
                return UIImage(systemName: systemName) ?? loadImageSafely(with: assetsFallback)
            } else {
                return loadImageSafely(with: assetsFallback)
            }
        }
        
        // MARK: - General
        
        public var back: UIImage = loadImageSafely(with: "call_back_icon")
        public var endCall: UIImage = loadImageSafely(with: "endCall")
        public var flipeCamera: UIImage = loadImageSafely(with: "flipeCamera")
        public var offMic: UIImage = loadImageSafely(with: "offMic")
        public var onMic: UIImage = loadImageSafely(with: "onMic")
        public var offVideo: UIImage = loadImageSafely(with: "offVideo")
        public var onVideo: UIImage = loadImageSafely(with: "onVideo")
        public var profile_avatar: UIImage = loadImageSafely(with: "profile_avatar")
        public var speakerOff: UIImage = loadImageSafely(with: "speakerOff")
        public var speakerOn: UIImage = loadImageSafely(with: "speakerOn")
        public var profileAvatar : UIImage = loadImageSafely(with: "profile_avatar")
        public var group: UIImage = loadImageSafely(with: "group")
        public var minimize: UIImage = loadImageSafely(with: "minimize")
        
    }
}


public extension Appearance {
    struct SoundFiles {
        /// A private internal function that will safely load an image from the bundle or return a circle image as backup
        /// - Parameter imageName: The required image name to load from the bundle
        /// - Returns: A UIImage that is either the correct image from the bundle or backup circular image
        private static func loadSoundFileSafely(with soundName: String) -> String {
        
            if let path = Bundle.ismSwiftCall.path(forResource: soundName, ofType: "mp3") {
                return path
            } else {
                print(
                    """
                    \(soundName) path has failed to load from the bundle please make sure it's included in your resources folder.
                    """
                )
                return ""
            }
        }
        
        
        // MARK: - General
        
        public var ringer : String = loadSoundFileSafely(with: "phone_ringer")
        
    }
}
