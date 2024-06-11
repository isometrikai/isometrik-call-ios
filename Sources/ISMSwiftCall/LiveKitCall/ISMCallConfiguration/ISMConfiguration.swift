//
//  File.swift
//  
//
//  Created by Ajay Thakur on 11/06/24.
//

import Foundation

public class ISMConfiguration{
    public static let shared = ISMConfiguration()
    
    private var callConfiguration: ISMCallConfiguration?
    
    private init() {}
    
     func setCallConfiguration(configuration: ISMCallConfiguration) {
        callConfiguration = configuration
    }
    public func setUserId(_ userId: String) {
         callConfiguration?.userId = userId
    }
    
    public func getUserId() -> String {
        guard let userId = callConfiguration?.userId else {
                   print("Isometrik User ID is nil. Please set it before calling getUserId().")
                   return ""
               }
               return userId
    }
    
    public func setUserToken(_ userToken: String) {
        callConfiguration?.userToken = userToken
    }
    public func getUserToken() -> String {
        guard let userToken = callConfiguration?.userToken else {
                   print("Isometrik User Token is nil. Please set it before calling getUserToken().")
                   return ""
               }
               return userToken
    }
    
    public func videoCallOptionEnabled() -> Bool {
        return callConfiguration?.videoCallOption ?? false
    }
    
    public func appSecret() -> String {
        guard let appSecret = callConfiguration?.appSecret else {
                   print("App Secret is nil. Please set it before calling appSecret().")
                   return ""
               }
               return appSecret
    }
    public func licenseKey() -> String {
        guard let licenseKey = callConfiguration?.licenseKey else {
                   print("license Key is nil. Please set it before calling licenseKey().")
                   return ""
               }
               return licenseKey
    }
    public func userSecret() -> String {
        guard let userSecret = callConfiguration?.userSecret else {
                   return ""
               }
               return userSecret
    }
    
    public func getAccountId() -> String{
        
        return callConfiguration?.accountId ?? ""
    }
    
    public func getKeySetId() -> String{
        return callConfiguration?.keysetId ?? ""
    }
    
    public func getProjectId() -> String{
        
        return callConfiguration?.projectId ?? ""
    }
    
    public func getMQTTHost() -> String{
        return callConfiguration?.MQTTHost ?? ""
    }
    public func getMQTTPort() -> Int{
        
        return callConfiguration?.MQTTPort ?? 2052
    }
    
    public func getCallHangUpTime() -> TimeInterval{
        
        return callConfiguration?.callHangupTimeOnNoAnswer ?? 60.0
    }
    
    public func getIsometrikLiveStreamUrl() -> String{
        return callConfiguration?.isometrikLiveStreamUrl ?? ""
        
    }
    
}
