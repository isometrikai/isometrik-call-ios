//
//  ISMLKAuth.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 23/09/23.
//

import Foundation

struct ISMCallAuth: Codable {
    let userToken, userId, msg: String
    
    enum CodingKeys: String, CodingKey {
        case userToken
        case userId
        case msg
    }
}

struct ISMUpdateUser: Codable {
   let msg: String?
}


class ISMPushKitToken {
    
    static let shared = ISMPushKitToken()
    
    // New token provided by push kit 
    var newToken : String?
    
    // last updated token on the server.
    var token : String?
    
    private init() {}
    
    func updatedOnServer(){
        token = newToken
    }
    
    func needToUpdate() -> Bool{
       return token != newToken
    }
    
    func clear() {
        token = nil
     }
}
