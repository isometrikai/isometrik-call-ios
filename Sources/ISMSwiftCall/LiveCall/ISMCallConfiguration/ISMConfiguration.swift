//
//  File.swift
//  
//
//  Created by Ajay Thakur on 11/06/24.
//

import Foundation

 class ISMConfiguration{

    
    private var callConfiguration: ISMCallConfiguration?
     
    
     init(configuration: ISMCallConfiguration) {
         callConfiguration = configuration
         self.setAccountId()
         self.setProjectId()
         self.setKeysetId()
         self.setLicenseKey()
         self.setAppSecret()
         self.setUserSecret()
         self.setIsometrikLiveStreamUrl()
         self.setMQTTHost()
        
     }

     
     func setAccountId() {

         do {
             guard let data = callConfiguration?.accountId.data(using: .utf8) else {
                 return
             }
             try KeychainWrapper.set(value: data, account: "accounId")
         }catch{
             //handle error
         }
    }
     
     func setProjectId() {

         do {
             guard let data = callConfiguration?.projectId.data(using: .utf8) else {
                 return
             }
             try KeychainWrapper.set(value: data, account: "projectId")
         }catch{
             //handle error
         }
    }
     
     func setKeysetId() {

         do {
             guard let data = callConfiguration?.keysetId.data(using: .utf8) else {
                 return
             }
             try KeychainWrapper.set(value: data, account: "keysetId")
         }catch{
             //handle error
         }
    }
     
     
     func setLicenseKey() {

         do {
             guard let data = callConfiguration?.licenseKey.data(using: .utf8) else {
                 return
             }
             try KeychainWrapper.set(value: data, account: "licenseKey")
         }catch{
             //handle error
         }
    }
     
     func setAppSecret() {

         do {
             guard let data = callConfiguration?.appSecret.data(using: .utf8) else {
                 return
             }
             try KeychainWrapper.set(value: data, account: "appSecret")
         }catch{
             //handle error
         }
    }
     
     func setUserSecret() {

         do {
             guard let data = callConfiguration?.userSecret.data(using: .utf8) else {
                 return
             }
             try KeychainWrapper.set(value: data, account: "userSecret")
         }catch{
             //handle error
         }
    }
     
     func setIsometrikLiveStreamUrl() {

         do {
             guard let data = callConfiguration?.isometrikLiveStreamUrl.data(using: .utf8) else {
                 return
             }
             try KeychainWrapper.set(value: data, account: "isometrikLiveStreamUrl")
         }catch{
             //handle error
         }
    }
     
     func setMQTTHost() {

         do {
             guard let data = callConfiguration?.MQTTHost.data(using: .utf8) else {
                 return
             }
             try KeychainWrapper.set(value: data, account: "MQTTHost")
         }catch{
             //handle error
         }
    }
    

     static func getAccountId() -> String {
         do {
             let data = try KeychainWrapper.get(account: "accounId")
             guard let data, let accountId = String(data: data, encoding: .utf8) else {
                 print("Account ID is nil. Please set it before calling getAccountId().")
                 return ""
             }
             return accountId
         } catch {
             print("Failed to retrieve Account ID: \(error)")
             return ""
         }
     }

     static func getProjectId() -> String {
         do {
             let data = try KeychainWrapper.get(account: "projectId")
             guard let data, let projectId = String(data: data, encoding: .utf8) else {
                 print("Project ID is nil. Please set it before calling getProjectId().")
                 return ""
             }
             return projectId
         } catch {
             print("Failed to retrieve Project ID: \(error)")
             return ""
         }
     }

     static func getKeysetId() -> String {
         do {
             let data = try KeychainWrapper.get(account: "keysetId")
             guard let data, let keysetId = String(data: data, encoding: .utf8) else {
                 print("Keyset ID is nil. Please set it before calling getKeysetId().")
                 return ""
             }
             return keysetId
         } catch {
             print("Failed to retrieve Keyset ID: \(error)")
             return ""
         }
     }

     static func getLicenseKey() -> String {
         do {
             let data = try KeychainWrapper.get(account: "licenseKey")
             guard let data, let licenseKey = String(data: data, encoding: .utf8) else {
                 print("License Key is nil. Please set it before calling getLicenseKey().")
                 return ""
             }
             return licenseKey
         } catch {
             print("Failed to retrieve License Key: \(error)")
             return ""
         }
     }

     static func getAppSecret() -> String {
         do {
             let data = try KeychainWrapper.get(account: "appSecret")
             guard let data, let appSecret = String(data: data, encoding: .utf8) else {
                 print("App Secret is nil. Please set it before calling getAppSecret().")
                 return ""
             }
             return appSecret
         } catch {
             print("Failed to retrieve App Secret: \(error)")
             return ""
         }
     }

     static func getUserSecret() -> String {
         do {
             let data = try KeychainWrapper.get(account: "userSecret")
             guard let data, let userSecret = String(data: data, encoding: .utf8) else {
                 print("User Secret is nil. Please set it before calling getUserSecret().")
                 return ""
             }
             return userSecret
         } catch {
             print("Failed to retrieve User Secret: \(error)")
             return ""
         }
     }

    static func getIsometrikLiveStreamUrl() -> String {
         do {
             let data = try KeychainWrapper.get(account: "isometrikLiveStreamUrl")
             guard let data, let isometrikLiveStreamUrl = String(data: data, encoding: .utf8) else {
                 print("Isometrik Live Stream URL is nil. Please set it before calling getIsometrikLiveStreamUrl().")
                 return ""
             }
             return isometrikLiveStreamUrl
         } catch {
             print("Failed to retrieve Isometrik Live Stream URL: \(error)")
             return ""
         }
     }

     static func getMQTTHost() -> String {
         do {
             let data = try KeychainWrapper.get(account: "MQTTHost")
             guard let data, let MQTTHost = String(data: data, encoding: .utf8) else {
                 print("MQTT Host is nil. Please set it before calling getMQTTHost().")
                 return ""
             }
             return MQTTHost
         } catch {
             print("Failed to retrieve MQTT Host: \(error)")
             return ""
         }
     }

     
     static func getUserId() -> String {
         do {
              let userId = try KeychainWrapper.get(account: "userId")
             guard let userId , let userId = String(data:userId , encoding: .utf8) else {
                       print("Isometrik User ID is nil. Please set it before calling getUserId().")
                       return ""
                   }
                   return userId
         }catch{
             print("Isometrik User ID is nil. Please set it before calling getUserId().")
             return ""
         }
    }
    
    
    static func getUserToken() -> String {
         do {
              let userId = try KeychainWrapper.get(account: "userToken")
             guard let userId , let userId = String(data:userId , encoding: .utf8) else {
                       print("Isometrik user Token is nil. Please set it before calling getUserToken().")
                       return ""
                   }
                   return userId
         }catch{
             print("Isometrik user Token is nil. Please set it before calling getUserToken().")
             return ""
         }
    
    }
    
static func videoCallOptionEnabled() -> Bool {
     return  true
    }
}
