//
//  ISMCallConfiguration.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 13/09/23.
//

import Foundation

public protocol ISMCallConfigurationProtocol {
    var accountId: String { get }
    var projectId: String { get }
    var keysetId: String { get }
    
    var licenseKey: String { get }
    var appSecret: String { get }
    var userSecret: String { get }
    
    var isometrikLiveStreamUrl: String { get }
    var userToken: String { get set }
    var userId: String { get set }
    var MQTTHost: String { get }
    var MQTTPort: Int { get }
    var videoCallOption: Bool { get }
    var callHangupTimeOnNoAnswer: TimeInterval { get }
    
    mutating func updateUserId(_ userId: String)
    mutating func updateUserToken(_ userToken: String)
}

public struct ISMCallConfiguration: ISMCallConfigurationProtocol {
    mutating public func updateUserId(_ userId: String) {
        self.userId = userId
    }
    
    mutating public func updateUserToken(_ userToken: String) {
        self.userToken = userToken
    }
    
    public let accountId: String
    public let projectId: String
    public let keysetId: String
    public let licenseKey: String
    public let appSecret: String
    public let userSecret: String
    public var userToken: String
    public var userId: String
    
    public let isometrikLiveStreamUrl: String
    public var MQTTHost: String
    public var MQTTPort: Int
    public var videoCallOption: Bool
    public var callHangupTimeOnNoAnswer: TimeInterval

    init(accountId: String, projectId: String, keysetId: String, licenseKey: String, appSecret: String, userSecret: String, iometrikLiveStreamUrl userToken: String, userToken userId: String, userId isometrikLiveStreamUrl: String = "wss://streaming.isometrik.io", MQTTHost: String = "connections.isometrik.io", MQTTPort: Int = 2052, videoCallOption: Bool = true, callHangupTimeOnNoAnswer: TimeInterval = 60.0) {
        self.accountId = accountId
        self.projectId = projectId
        self.keysetId = keysetId
        self.licenseKey = licenseKey
        self.appSecret = appSecret
        self.userSecret = userSecret
        self.isometrikLiveStreamUrl = isometrikLiveStreamUrl
        self.userToken = userToken
        self.userId = userId
        self.MQTTHost = MQTTHost
        self.MQTTPort = MQTTPort
        self.videoCallOption = videoCallOption
        self.callHangupTimeOnNoAnswer = callHangupTimeOnNoAnswer
    }
}





