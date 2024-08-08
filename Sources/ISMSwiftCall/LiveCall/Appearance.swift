//
//  File.swift
//  
//
//  Created by Ajay Thakur on 12/06/24.
//

import Foundation
import UIKit

/// An object containing visual configuration for whole application.
public struct Appearance {
    /// A set of images to be used.
    ///
    /// By providing different object or changing individual images, you can change the look of the views.
    public var images = Images()
    
    public var soundFiles = SoundFiles()

    /// Provider for custom localization which is dependent on App Bundle.
    public var localizationProvider: (_ key: String, _ table: String) -> String = { key, table in
        Bundle.ismSwiftCall.localizedString(forKey: key, value: nil, table: table)
    }

    public init() {}
}

// MARK: - Appearance + Default

public extension Appearance {
    static var `default`: Appearance = .init()
}
