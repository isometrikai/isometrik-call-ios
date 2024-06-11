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


public struct ISMCallMember: Codable, Hashable {
    public let memberName, memberIdentifier, memberId: String?
    public let isPublishing, isAdmin: Bool?
    public var memberProfileImageURL : String?
    
    
    init(memberName: String?, memberIdentifier: String?, memberId: String?, isPublishing: Bool? = false, isAdmin: Bool? = false, memberProfileImageURL: String? = nil) {
        self.memberName = memberName
        self.memberIdentifier = memberIdentifier
        self.memberId = memberId
        self.isPublishing = isPublishing
        self.isAdmin = isAdmin
        self.memberProfileImageURL = memberProfileImageURL
    }

}
