//
//  File.swift
//  
//
//  Created by Ajay Thakur on 11/06/24.
//

import Foundation
public class IsometrikCall {

    public init(){}
    public init(configuration: ISMCallConfiguration) {
      _ =  ISMConfiguration(configuration: configuration)
    }
    

    public func isConfigured() -> Bool {
           return true
       }
    
    
    public func startCall(with member: ISMCallMember, callType: ISMLiveCallType = .AudioCall) {
//        guard let config = configuration else {
//                   print("Isometrik SDK is not configured.")
//                   return
//               }
//               
//               guard config.userId != nil && config.userToken != nil else {
//                   print("Isometrik User ID and/or Isometrik User Token is not set.")
//                   return
//               }

        ISMCallManager.shared.createCall(callUser: member, callType: callType)
    }
    

    
    public func updateUserId(_ userId: String) {
       
        do {
            guard let data = userId.data(using: .utf8) else {
                return
            }
            try KeychainWrapper.set(value: data, account: "userId")
        }catch{
            //handle error
        }
    }
    
    public func updateUserToken(_ userToken: String) {
        do {
            guard let data = userToken.data(using: .utf8) else {
                return
            }
            try KeychainWrapper.set(value: data, account: "userToken")
        }catch{
            //handle error
        }
    }
    
    public func createMqttConnection(){
        
        guard !ISMConfiguration.getUserId().isEmpty else {
            print("Cannot start call: User ID is not set.")
            return
        }
        ISMMQTTManager.shared.connect(clientId: ISMConfiguration.getUserId())
    }
    
    public func clearSession(){
        do{
            try KeychainWrapper.deleteAll()
        }catch{
            
        }
    }
    
}

