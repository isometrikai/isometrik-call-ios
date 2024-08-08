//
//  ISMCallAuthRequest.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 14/09/23.
//

import Foundation

struct ISMAuthRequest : Codable{
    let userIdentifier : String
    let password : String
}

struct ISMUpdateUserRequest : Codable{
    let addApnsDeviceToken : Bool
    let apnsDeviceToken : String
}
