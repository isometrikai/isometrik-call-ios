//
//  File.swift
//  
//
//  Created by Ajay Thakur on 11/06/24.
//

import Foundation
public class IsometrikCall {
    public static let shared = IsometrikCall()
    private var configuration: ISMCallConfiguration?

    private init() {}
    
    public init(configuration: ISMCallConfiguration) {
        self.configuration = configuration
         ISMConfiguration.shared.setCallConfiguration(configuration: configuration)
    }
    
    public func configure(with configuration: ISMCallConfiguration) {
          self.configuration = configuration
      }
    
    public func getConfiguration() -> ISMCallConfiguration? {
           return configuration
       }
    
    public  func isConfigured() -> Bool {
           return configuration != nil
       }
    
    
    public func startCall(with member: ISMCallMember, callType: ISMLiveCallType = .AudioCall) {
        guard let config = configuration else {
                   print("Isometrik SDK is not configured.")
                   return
               }
               
               guard config.userId != nil && config.userToken != nil else {
                   print("Isometrik User ID and/or Isometrik User Token is not set.")
                   return
               }

        ISMCallManager.shared.createCall(callUser: member, callType: callType)
    }
    
    public func updateUserId(_ userId: String) {
        configuration?.userId = userId
        ISMConfiguration.shared.setUserId(userId)
    }
    
    public func updateUserToken(_ userToken: String) {
        configuration?.userToken = userToken
        ISMConfiguration.shared.setUserToken(userToken)
    }
    
    public func createMqttConnection(){
        
        guard !ISMConfiguration.shared.getUserId().isEmpty else {
            print("Cannot start call: User ID is not set.")
            return
        }
        ISMMQTTManager.shared.connect(clientId: ISMConfiguration.shared.getUserId())
    }
    
}

