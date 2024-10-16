//
//  File.swift
//  
//
//  Created by Ajay Thakur on 03/08/24.
//

import Foundation
import PushKit
import CallKit
import AVFAudio

// PushRegistry methods
public extension ISMCallManager{
    
    
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard type == .voIP else {
            return
        }
        
        let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        ISMPushKitToken.shared.newToken = token
        self.updatePushRegisteryToken()
    }
    
    func updatePushRegisteryToken(){
        if !ISMConfiguration.getUserToken().isEmpty ,let token =  ISMPushKitToken.shared.newToken,   ISMPushKitToken.shared.needToUpdate(){
            viewModel.updatePushRegisteryApnsToken(addApnsDeviceToken: true, apnsDeviceToken: token) {
                ISMPushKitToken.shared.updatedOnServer()
            }
        }
    }
    
    
    
    
    
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: (() -> Void)?){
        
        guard type == .voIP else {
            return
        }
        
        
        do {
            let data = try JSONSerialization.data(withJSONObject: payload.dictionaryPayload, options: [])
            
            let pushPayload = try JSONDecoder().decode(ISMMeeting.self, from: data)
            
            let callDetails = pushPayload
            
            
            let handleName = callDetails.callType() == .GroupCall ? callDetails.meetingDescription ?? "Group Call" : callDetails.initiatorName ?? ""
            
            let update = CXCallUpdate()
            update.remoteHandle = CXHandle(type: .generic, value: handleName)
            
            // 2: Create and set configurations about how the calling application should behave
            
            if #available(iOS 14.0, *) {
                update.hasVideo = callDetails.callType() == .VideoCall
                provider.setDelegate(self, queue: nil)
                let newCall =  UUID()
                provider.reportNewIncomingCall(with:newCall, update: update, completion: { error in
                    if error == nil{
                        
                        if !ISMMQTTManager.shared.hasConnected{
                            ISMMQTTManager.shared.connect(clientId: ISMConfiguration.getUserId())
                        }
                        ISMCallManager.shared.callDetails = callDetails
                      
                        ISMCallManager.shared.addCall(uuid: newCall)
                        
                        ISMCallManager.shared.members = callDetails.members
                        
                        self.scheduleCallHangup()
                        
                        if callDetails.callType() != .GroupCall{
                            ISMCallManager.shared.publishMessage(message: .callRingingMessage)
                        }
                        
                        DispatchQueue.global(qos: .default).async {
                            do {
                                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .voiceChat)
                            } catch {
                                print("audioSession error: \(error.localizedDescription)")
                            }
                        }
                        
                        completion?()
                    }
                })
                
            }
            
        } catch {
            let update = CXCallUpdate()
            update.remoteHandle = CXHandle(type: .generic, value: "Unknown")
            
            provider.reportNewIncomingCall(with:UUID(), update: update) { error in
                print("Error decoding push payload: \(String(describing: error))")
                completion?()
            }
            
        }
        
    }
    
    func invalidatePushKitAPNSDeviceToken(_ registry: PKPushRegistry? = nil, type: PKPushType){
        guard type == .voIP, let token = ISMPushKitToken.shared.token else {
            return
        }
        self.viewModel.updatePushRegisteryApnsToken(addApnsDeviceToken: false, apnsDeviceToken: token) {
            ISMPushKitToken.shared.clear()
        }
    }
}
