//
//  ISMMeetingRequest.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 13/09/23.
//

import Foundation



public struct ISMMeetingRequest: Codable {
    public    var selfHosted : Bool = true
    public   var pushNotifications: Bool = true
    public  var metaData: [String : String]
    public  let members: [String]
    public  var meetingImageUrl: String
    public  var meetingDescription: String
    public var hdMeeting = false
    public var enableRecording: Bool = false
    public var deviceId : String
    public var customType: String
    public var meetingType: Int
    public  var autoTerminate = true
    public var audioOnly: Bool
    public var conversationId : String?
    
   public init(selfHosted: Bool = true, pushNotifications: Bool = true, metaData: [String : String] = [:], members: [String], meetingImageUrl: String = "https://d1q6f0aelx0por.cloudfront.net/product-logos/cb773227-1c2c-42a4-a527-12e6f827c1d2-elixir.png", meetingDescription: String = "NA", hdMeeting: Bool = false, enableRecording: Bool = false, deviceId: String = ISMDeviceId, customType: String, meetingType: Int = 0, autoTerminate: Bool = true, audioOnly: Bool, conversationId: String? = nil) {
        self.selfHosted = selfHosted
        self.pushNotifications = pushNotifications
        self.metaData = metaData
        self.members = members
        self.meetingImageUrl = meetingImageUrl
        self.meetingDescription = meetingDescription
        self.hdMeeting = hdMeeting
        self.enableRecording = enableRecording
        self.deviceId = deviceId
        self.customType = customType
        self.meetingType = meetingType
        self.autoTerminate = autoTerminate
        self.audioOnly = audioOnly
        self.conversationId = conversationId
    }
}
