//
//  File.swift
//  
//
//  Created by Ajay Thakur on 11/06/24.
//

import Foundation
public class IsometrikCall {
    
     init(configuration: ISMCallConfiguration) {
         ISMConfiguration.shared.setCallConfiguration(configuration: configuration)
    }
    
    public func startCall(with member: ISMCallMember, callType: ISMLiveCallType = .AudioCall) {
        guard !ISMConfiguration.shared.getUserId().isEmpty else {
            print("Cannot start call: User ID is not set.")
            return
        }

        ISMCallManager.shared.createCall(callUser: member, callType: callType)
    }
    
    public func updateUserId(_ userId: String) {
        ISMConfiguration.shared.setUserId(userId)
    }
    
    public func updateUserToken(_ userToken: String) {
        ISMConfiguration.shared.setUserToken(userToken)
    }
    
}
