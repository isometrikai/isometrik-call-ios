//
//  File.swift
//  
//
//  Created by Ajay Thakur on 11/06/24.
//

import Foundation

 class ISMConfiguration{
     static let shared = ISMConfiguration()
    
    private var callConfiguration: ISMCallConfiguration?
    
    private init() {}
    
      func setCallConfiguration(configuration: ISMCallConfiguration) {
        callConfiguration = configuration
    }
     func setUserId(_ userId: String) {
        callConfiguration?.updateUserId(userId)
    }
    
     func getUserId() -> String {
        guard let userId = callConfiguration?.userId else {
                   print("Isometrik User ID is nil. Please set it before calling getUserId().")
                   return ""
               }
               return userId
    }
    
     func setUserToken(_ userToken: String) {
        callConfiguration?.updateUserToken(userToken)
    }
     func getUserToken() -> String {
        guard let userToken = callConfiguration?.userToken else {
                   print("Isometrik User Token is nil. Please set it before calling getUserToken().")
                   return ""
               }
               return userToken
    }
    
     func videoCallOptionEnabled() -> Bool {
        return callConfiguration?.videoCallOption ?? false
    }
    
     func appSecret() -> String {
        guard let appSecret = callConfiguration?.appSecret else {
                   print("App Secret is nil. Please set it before calling appSecret().")
                   return ""
               }
               return appSecret
    }
     func licenseKey() -> String {
        guard let licenseKey = callConfiguration?.licenseKey else {
                   print("license Key is nil. Please set it before calling licenseKey().")
                   return ""
               }
               return licenseKey
    }
     func userSecret() -> String {
        guard let userSecret = callConfiguration?.userSecret else {
            print("User Secret is nil. Please set it before calling userSecret().")
                   return ""
               }
               return userSecret
    }
    
     func getAccountId() -> String{
        
        return callConfiguration?.accountId ?? ""
    }
    
     func getKeySetId() -> String{
        return callConfiguration?.keysetId ?? ""
    }
    
     func getProjectId() -> String{
        
        return callConfiguration?.projectId ?? ""
    }
    
     func getMQTTHost() -> String{
        return callConfiguration?.MQTTHost ?? ""
    }
     func getMQTTPort() -> Int{
        
        return callConfiguration?.MQTTPort ?? 2052
    }
    
     func getCallHangUpTime() -> TimeInterval{
        
        return callConfiguration?.callHangupTimeOnNoAnswer ?? 60.0
    }
    
     func getIsometrikLiveStreamUrl() -> String{
        return callConfiguration?.isometrikLiveStreamUrl ?? ""
        
    }
    
}
