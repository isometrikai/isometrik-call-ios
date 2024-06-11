//
//  ISMMeetingRequest.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 13/09/23.
//

import Foundation



struct ISMMeetingRequest: Codable {
    var selfHosted : Bool = true
    var pushNotifications: Bool = true
    var metaData: [String : String] = [:]
    let members: [String]
    var meetingImageUrl: String = "https://d1q6f0aelx0por.cloudfront.net/product-logos/cb773227-1c2c-42a4-a527-12e6f827c1d2-elixir.png"
    var meetingDescription: String = "NA"
    var hdMeeting = false
    var enableRecording: Bool = false
    let deviceId : String
    var customType: String
    var meetingType: Int = 0
    var autoTerminate = true
    var audioOnly: Bool
    var conversationId : String?
}
