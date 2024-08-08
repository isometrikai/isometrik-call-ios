//
//  ISMPublishMessage.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 13/03/24.
//

import Foundation

// MARK: - Welcome
struct ISMPublishMessage: Codable {
    var deviceId : String
    var meetingId : String
    var messageType : String
    var metaData: [String : String] = [:]
    let body: String

}
