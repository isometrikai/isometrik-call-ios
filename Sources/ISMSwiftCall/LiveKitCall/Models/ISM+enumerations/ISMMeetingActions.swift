//
//  ISMMeetingActions.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 03/04/24.
//

import Foundation

enum ISMMeetingActions : String{
    
    case meetingCreated = "meetingCreated"
    case meetingEnded = "meetingEndedDueToNoUserPublishing"
    case memberLeft = "memberLeave"
    case publishingStarted = "publishingStarted"
    case messagePublished = "messagePublished"
    case joinRequestAccept = "joinRequestAccept"
    case joinRequestReject = "joinRequestReject"
    
}


