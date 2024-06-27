//
//  ISMLKMeetingEndPoints.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 23/09/23.
//

import Foundation

enum ISMCallMeetingEndpoints : ISMURLConvertible {

    case getMeetings
    case createMeeting
    case accpetMeeting
    case rejectMeeting
    case startPublishing
    case leaveMeeting(meetingId : String)
    case publishMessage
    case updateUser
    
    var baseURL: URL {
        return URL(string:"https://apis.isometrik.io")!
    }
    
    var path: String {
        switch self {
        case .getMeetings:
            return "/meetings/v1/meetings"
        case .createMeeting:
            return "/meetings/v1/meeting"
        case .startPublishing:
            return "/meetings/v1/publish/start"
        case .leaveMeeting:
            return "/meetings/v1/leave"
        case .publishMessage:
            return "/meetings/v1/publish/message"
        case .updateUser:
            return "/chat/user"
        case .accpetMeeting:
            return "/meetings/v1/accept"
        case .rejectMeeting:
            return "/meetings/v1/reject"
        }
    }
    
    var method: ISMHTTPMethod {
        switch self {
        case .getMeetings:
            return .get
        case .createMeeting:
            return .post
        case .startPublishing:
            return .post
        case .leaveMeeting:
            return .delete
        case .publishMessage:
            return .post
        case .updateUser:
            return .patch
        case .accpetMeeting:
            return .post
        case .rejectMeeting:
            return .post
        }
    }
    
    var queryParams: [String: String]? {
        switch self{
        case .getMeetings:
            return nil
        case .createMeeting:
            return nil
        case .startPublishing:
            return nil
        case .leaveMeeting(meetingId: let meetingId):
            return ["meetingId" : meetingId]
        case .publishMessage:
            return nil
        case .updateUser:
            return nil
        case .accpetMeeting:
            return nil
        case .rejectMeeting:
            return nil
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getMeetings,.createMeeting, .startPublishing,.leaveMeeting,.publishMessage,.updateUser,.accpetMeeting,.rejectMeeting:
            return ["appSecret":ISMConfiguration.getAppSecret(),
                    "userToken" : ISMConfiguration.getUserToken() ,
                    "licenseKey" : ISMConfiguration.getLicenseKey()
            ]
        }
    }
    
 
    
    
    
}


