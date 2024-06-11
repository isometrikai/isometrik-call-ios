//
//  MQTT+ISMCall.swift
//  LiveKitCall
//
//  Created by Ajay Thakur on 12/04/24.
//

import Foundation

extension ISMMQTTManager {
    
    
    func handleTheMeetingEvents(payload : [UInt8]){
        let meeting : ISMMeeting
        let data = Data(payload)
        do {
            // Decode Data into your Codable struct
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(jsonDict)
            }
            meeting = try JSONDecoder().decode(ISMMeeting.self, from: data)

           print(meeting)
        } catch {
            return
            print("Error decoding data: \(error)")
        }
        
        switch ISMMeetingActions(rawValue: meeting.action ?? ""){
            
        case .meetingCreated :
           
            ISMCallManager.shared.callDetails = meeting
        //    ISMCallManager.shared.reportIncomingCall(callDetails:meeting )
        case .meetingEnded:
            //End Call for everyone
            if let callID = ISMCallManager.shared.callIDs.first,  (ISMLiveCallView.shared.meetingId == meeting.meetingId || ISMCallManager.shared.callDetails?.meetingId ==  meeting.meetingId) {
                ISMLiveCallView.shared.disconnectCall()
                ISMCallManager.shared.endCall(callUUID: callID)
            }
      
        case .memberLeft, .joinRequestReject:
            if ISMCallManager.shared.callDetails?.meetingId == meeting.meetingId,let callID = ISMCallManager.shared.callIDs.first{
                ISMCallManager.shared.endCall(callUUID: callID)
            }
        case .publishingStarted, .joinRequestAccept :
            if let senderId =  meeting.userId, senderId != ISMConfiguration.shared.getUserId(), ISMCallManager.shared.outgoingCallID != nil{
                ISMCallManager.shared.startTheCall()
            }else if  meeting.userId ==  ISMConfiguration.shared.getUserId(),let callID = ISMCallManager.shared.callIDs.first, (ISMCallManager.shared.callAnsweredByDeviceId == nil)  {
               // Notes : handle the scenario for session multiple devices. If one device accept the call end for others
                ISMCallManager.shared.endCall(callUUID: callID)
            }
            
        case .messagePublished :
            if let senderId =  meeting.senderId, senderId != ISMConfiguration.shared.getUserId(), let messageBody = meeting.body{
                switch ISMPublishMessageConstants(rawValue: messageBody) {
                case .callRingingMessage:
                    ISMLiveCallView.shared.updateCallStatus(.ringing)
                case .requestToSwitchToVideoCall :
                    ISMLiveCallView.shared.showTheVideoCallRequest(meeting: meeting)
                case .requestToSwitchToVideoCallRejected:
                    ISMLiveCallView.shared.videoCallRequestDeclined()
                case .requestToSwitchToVideoCallAccepted:
                    ISMLiveCallView.shared.switchToVideoCallrequestAccepted()
                default :
                    break
                }
           
            }
        default :
            print("")
        }
        
    }
}
