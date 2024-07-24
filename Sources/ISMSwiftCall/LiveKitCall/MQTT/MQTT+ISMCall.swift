//
//  MQTT+ISMCall.swift
//  LiveKitCall
//
//  Created by Ajay Thakur on 12/04/24.
//

import Foundation

public protocol CallEventHandlerDelegate: AnyObject {
    func didReceiveMeetingCreated(meeting: ISMMeeting?)
    func didReceiveMeetingEnded(meeting: ISMMeeting?)
    func publishingStarted(meeting: ISMMeeting?)
    func didMemberLeaveTheMeeting(meeting: ISMMeeting?)
    func didReceiveJoinRequestReject(meeting: ISMMeeting?)
    func didReceiveJoinRequestAccept(meeting: ISMMeeting?)
    func didReceiveMessagePublished(meeting: ISMMeeting?, messageBody: String)
}


public struct CallEventHandler {
    
    public static weak var delegate: CallEventHandlerDelegate?
    public  static func handleCallEvents(payload : [UInt8]){
        let meeting : ISMMeeting?
        let data = Data(payload)
        do {
            // Decode Data into your Codable struct
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(jsonDict)
            }
            meeting = try JSONDecoder().decode(ISMMeeting.self, from: data)
        } catch {
            meeting = nil
            print("Error decoding data: \(error)")
        }
        
        switch ISMMeetingActions(rawValue: meeting?.action ?? ""){
            
        case .meetingCreated :
           
            ISMCallManager.shared.callDetails = meeting
            delegate?.didReceiveMeetingCreated(meeting: meeting)

        case .meetingEnded:
            //End Call for everyone
            if let callID = ISMCallManager.shared.callIDs.first,  (ISMLiveCallView.shared.meetingId == meeting?.meetingId || ISMCallManager.shared.callDetails?.meetingId ==  meeting?.meetingId) {
                ISMLiveCallView.shared.disconnectCall()
                ISMCallManager.shared.endCall(callUUID: callID)
            }
            delegate?.didReceiveMeetingEnded(meeting: meeting)
        case .memberLeft :
            delegate?.didMemberLeaveTheMeeting(meeting: meeting)
       case .joinRequestReject:
            if ISMCallManager.shared.callDetails?.meetingId == meeting?.meetingId,let callID = ISMCallManager.shared.callIDs.first{
//                ISMCallManager.shared.endCall(callUUID: callID)
                ISMLiveCallView.shared.showNoAnswerView()
            }
            delegate?.didReceiveJoinRequestReject(meeting: meeting)
        case .publishingStarted :
            delegate?.publishingStarted(meeting: meeting)
        case .joinRequestAccept :
            if let senderId =  meeting?.userId, senderId != ISMConfiguration.getUserId(), ISMCallManager.shared.outgoingCallID != nil{
                ISMCallManager.shared.startTheCall()
            }else if  meeting?.userId ==  ISMConfiguration.getUserId(),let callID = ISMCallManager.shared.callIDs.first, (ISMCallManager.shared.callActiveOnDeviceId == nil)  {
               // Notes : handle the scenario for session multiple devices. If one device accept the call end for others
                ISMCallManager.shared.endCall(callUUID: callID)
            }
            delegate?.didReceiveJoinRequestAccept(meeting: meeting)
        case .messagePublished :
            if let senderId =  meeting?.senderId, senderId != ISMConfiguration.getUserId(), let messageBody = meeting?.body{
                switch ISMPublishMessageConstants(rawValue: messageBody) {
                case .callRingingMessage:
                    ISMLiveCallView.shared.updateCallStatus(.ringing)
                case .requestToSwitchToVideoCall :
                    if let meeting {
                        ISMLiveCallView.shared.showTheVideoCallRequest(meeting: meeting)
                    }
                case .requestToSwitchToVideoCallRejected:
                    ISMLiveCallView.shared.videoCallRequestDeclined()
                case .requestToSwitchToVideoCallAccepted:
                    ISMLiveCallView.shared.switchToVideoCallrequestAccepted()
                default :
                    break
                }
                delegate?.didReceiveMessagePublished(meeting: meeting, messageBody:messageBody )
            }
          
        default :
            print("")
        }
        
    }
}
