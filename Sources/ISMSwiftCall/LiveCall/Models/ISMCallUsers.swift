//
//  ISMUser.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 14/09/23.
//

import Foundation

// MARK: - Welcome
struct ISMCallUsers: Codable {
    let users: [ISMCallUser]
    let msg: String
}

// MARK: - User
public struct ISMCallUser: Codable, Hashable {
    let userProfileImageURL: String
    public  let userName, userIdentifier, userID: String
    let updatedAt: Int
    let notification: Bool
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case userProfileImageURL = "userProfileImageUrl"
        case userName, userIdentifier
        case userID = "userId"
        case updatedAt, notification, createdAt
    }
}

// MARK: - Welcome
struct ISMAuthErrors: Codable {
    let errors: ISMAuthError
}

// MARK: - Errors
struct ISMAuthError: Codable {
    let password: [String]
}

public struct ISMMeetingMembers: Codable, Hashable {
    let membersCount : Int?
    let meetingMembers : [ISMCallMember]?
}

public struct ISMCallMember: Codable, Hashable {
    public let memberName, memberIdentifier, memberId: String?
    public let isPublishing, isAdmin: Bool?
    public var memberProfileImageURL : String?
    
    public let userName, userID, userIdentifier: String?
    public let isHost: Bool?
    public let accepted: Bool?
    public let userProfileImageURL: String?
    public let deviceID: String?
    public let metaData: MemberMetaData?
    public let online: Bool?
    public let lastSeen: Int?
    public let joinTime: Int?
//    
    enum CodingKeys: String, CodingKey {
        
          case userName,memberName
          case userID = "userId"
          case memberId = "memberId"
          case userIdentifier, isHost, isPublishing, accepted,memberIdentifier
          case userProfileImageURL = "userProfileImageUrl"
          case memberProfileImageURL = "memberProfileImageURL"
          case deviceID = "deviceId"
          case metaData, online, lastSeen, isAdmin, joinTime
      }
    
    public init(memberName: String?, memberIdentifier: String?, memberId: String?, isPublishing: Bool? = false, isAdmin: Bool? = false, memberProfileImageURL: String? = nil) {
        self.memberName = memberName
        self.memberIdentifier = memberIdentifier
        self.memberId = memberId
        self.isPublishing = isPublishing
        self.isAdmin = isAdmin
        self.memberProfileImageURL = memberProfileImageURL
        
        self.userName = memberName
        self.userID = memberId
        self.userIdentifier = memberIdentifier
        self.isHost = isAdmin
        self.accepted = nil
        self.userProfileImageURL = self.memberProfileImageURL
        self.deviceID = ""
        self.metaData = nil
        self.online = nil
        self.lastSeen = nil
        self.joinTime = nil
    }

}

extension ISMCallMember {
    init(from member: ISMCallUser) {
        self.memberName = member.userName
        self.memberIdentifier = member.userIdentifier
        self.memberId = member.userID
        self.isPublishing = nil
        self.isAdmin = nil
        self.memberProfileImageURL = ""
        self.userName = memberName
        self.userID = memberId
        self.userIdentifier = memberIdentifier
        self.isHost = isAdmin
        self.accepted = nil
        self.userProfileImageURL = self.memberProfileImageURL
        self.deviceID = ""
        self.metaData = nil
        self.online = nil
        self.lastSeen = nil
        self.joinTime = nil
    }
}


// MARK: - MetaData
public struct MemberMetaData: Codable,Hashable {
    public let country : String?
    
    enum CodingKeys: String, CodingKey {
        case country = "country"
    }
}
