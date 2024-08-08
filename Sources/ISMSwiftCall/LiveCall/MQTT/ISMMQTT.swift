//
//  ISMMQTT.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 03/03/24.
//

import CocoaMQTT
import Foundation
import UIKit

public class ISMMQTTManager : NSObject {
    
    
    
    //MARK:  - PROPERTIES
    var mqtt: CocoaMQTT?
    var clientId : String = ""
    public   static let shared = ISMMQTTManager()
    let deviceId = ISMDeviceId

    var hasConnected : Bool = false
    
    //MARK: - CONFIGURE
    public  func connect(clientId : String){
        self.clientId = clientId
        mqtt = CocoaMQTT(clientID: clientId + (deviceId ), host: ISMConfiguration.getMQTTHost(), port: UInt16(2052))
        mqtt?.username = "2" + ISMConfiguration.getAccountId() + ISMConfiguration.getProjectId()
        mqtt?.password = ISMConfiguration.getLicenseKey() + ISMConfiguration.getKeysetId()
        mqtt?.keepAlive = 60
        mqtt?.autoReconnect = true
        mqtt?.logLevel = .debug
       _ = mqtt?.connect()
        mqtt?.delegate = self
        mqtt?.didConnectAck = { mqtt, ack in
            if ack == .accept{
                let client = clientId
                let messageTopic =
                "/\(ISMConfiguration.getAccountId())/\(ISMConfiguration.getProjectId())/Message/\(client)"
                let statusTopic =
                "/\(ISMConfiguration.getAccountId())/\(ISMConfiguration.getProjectId())/Status/\(client)"
                mqtt.subscribe([(messageTopic,.qos0),(statusTopic,qos: .qos0)])
                self.hasConnected = true
            }
        }
    }
    
    public  func unSubscribe(){
        let client = self.clientId
        let messageTopic =
        "/\(ISMConfiguration.getAccountId())/\(ISMConfiguration.getProjectId())/Message/\(client)"
        let statusTopic =
        "/\(ISMConfiguration.getAccountId())/\(ISMConfiguration.getProjectId())/Status/\(client)"
        mqtt?.unsubscribe(messageTopic)
        mqtt?.unsubscribe(statusTopic)
    }
    
    open func addObserverForMQTT(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        NotificationCenter.default.addObserver(observer, selector: aSelector, name: aName, object: anObject)
    }
    
    open func removeObserverForMQTT(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        NotificationCenter.default.removeObserver(observer, name: aName, object: anObject)
    }
}

extension ISMMQTTManager : CocoaMQTTDelegate{
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {

    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {

    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {

    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        CallEventHandler.handleCallEvents(payload: message.payload)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
  
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {

    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {

    }
    
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
      
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
      hasConnected = false
    }
}


