//
//  ISMISMCallManager.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 28/02/24.
//

import Foundation
import CallKit
import UIKit
import AVFAudio
import PushKit


public class ISMCallManager: NSObject {
    
    /// Singleton instance
    public static let shared = ISMCallManager()
    
    // Call management properties
    private var callHangupTimer: ISMCallHangupTimer?
    private(set) var callIDs: [UUID] = []
    var backgroundTaskID: UIBackgroundTaskIdentifier?
    var callDetails: ISMMeeting?
    var members: [ISMCallMember]?
    var outgoingCallID: UUID?
    var callConnectedTime: Date?
    var callActiveOnDeviceId: String?
    
    // CallKit properties
    let callController = CXCallController()
    let callObserver = CXCallObserver()
    let audioSession = AVAudioSession.sharedInstance()
    let provider = CXISMCallManager.shared.provider
    
    // View model
    let viewModel = ISMCallMeetingViewModel()
    
    // MARK: - Initializers
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioRouteChange(notification:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }

    
    // MARK: Call Management
    func containsCall(uuid: UUID) -> Bool {
        return ISMCallManager.shared.callIDs.contains(where: { $0 == uuid })
    }
    
    func addCall(uuid: UUID) {
        self.callIDs.append(uuid)
    }
    
    func removeCall(uuid: UUID) {
        self.callIDs.removeAll { $0 == uuid }
    }
    
    func removeAllCalls() {
        self.callIDs.removeAll()
    }
    
    
    func endCall(callUUID: UUID) {
        let endCallAction = CXEndCallAction(call: callUUID)
        let transaction = CXTransaction(action: endCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Error ending call: \(error.localizedDescription)")
                self.provider.reportCall(with: callUUID, endedAt: Date(), reason: .remoteEnded)
                DispatchQueue.main.async {
                    ISMLiveCallView.shared.disconnectCall()
                }
            } else {
                print("Call ended successfully")
                
            }
        }
    }
    
    
    func canMakeAOutgoingCall() -> Bool{
        
        if callObserver.calls.contains(where: { $0.hasConnected || $0.isOutgoing }) {
            // There is an active call, handle accordingly
            //            if let topController =  ISMLiveKitCallUtil.topPresentedController(){
            //                topController.showISMCallErrorAlerts(message:"You can not place a call if you're already on another call.")
            //            }
            return false
        } else {
            // There is no active call, proceed with making the outgoing call
            return true
        }
        
    }
    
    func reportOutgoingCall(handleName: String,token:String, meetingId : String,videoEnabled : Bool) {
        
        guard canMakeAOutgoingCall() else{
            return
        }
        
        
        let handle = CXHandle(type: .generic, value: handleName)
        
        provider.setDelegate(self, queue: nil)
        let newCall = UUID()
        
        outgoingCallID = newCall
        // Report outgoing call
        provider.reportOutgoingCall(with: newCall, startedConnectingAt: Date())
        // Start the call action
        let startCallAction = CXStartCallAction(call: newCall, handle: handle)
        startCallAction.isVideo = videoEnabled
        startCallAction.contactIdentifier = handleName
        let transaction = CXTransaction(action: startCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Error starting call: \(error.localizedDescription)")
            } else {
                print("Call started successfully")
                self.callActiveOnDeviceId = ISMDeviceId
                self.scheduleCallHangup()
            }
        }
    }
    
    // Start the call outgoing call if it is accepted on other end
    func startTheCall(){
        // add -2 to assume call is connected early to sync the time on incoming side.
        callConnectedTime = Date().addingTimeInterval(-2)
        self.cancelHangupTimer()
        self.outgoingCallID = nil // clear the outgoingCallId to avoid the hangup case of no answer
        self.provider.reportOutgoingCall(with: ISMCallManager.shared.callIDs.first!, connectedAt: callConnectedTime)
    }
    
    /// To report a call without the Pushkit.
    func reportIncomingCall(callDetails : ISMMeeting){
        // 1: Create an incoming call update object. This object stores different types of information about the caller. You can use it in setting whether the call has a video.
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: callDetails.initiatorName ?? "")
        
        // 2: Create and set configurations about how the calling application should behave
        if #available(iOS 14.0, *) {
            update.hasVideo = callDetails.callType() == .VideoCall
            provider.setDelegate(self, queue: nil)
            let newCall =  UUID()
            provider.reportNewIncomingCall(with:newCall, update: update, completion: { error in
                if error == nil{
                    ISMCallManager.shared.callDetails = callDetails
                    ISMCallManager.shared.publishMessage(message: .callRingingMessage)
                    ISMCallManager.shared.addCall(uuid: newCall)
                    ISMCallManager.shared.members = callDetails.members
                    
                }
            })
            
        }
        else {
            // Fallback on earlier versions
        }
    }
    
    /// hangup if  call is not connected within timeInterval seconds
    func scheduleCallHangup() {
#if !targetEnvironment(simulator)
        callHangupTimer = ISMCallHangupTimer(timeInterval: 60.0, hangupHandler: hangupCall)
        callHangupTimer?.start()
#endif
    }
    
    func cancelHangupTimer() {
        callHangupTimer?.cancel()
    }
    
    func hangupCall() {
        print("Call is being hung up due to no answer.")
        //Outgoing call
        if let callUUID = self.outgoingCallID {
            ISMLiveCallView.shared.showNoAnswerView()
        }//Incoming call
        else if let callUUID = self.callIDs.first {
            self.endCall(callUUID:callUUID)
            self.rejectCall()
        }
    }
}



class CallObserverDelegate: NSObject, CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if !call.hasConnected {
            print("Call changed before answering")
        } else {
            print("Call changed after answering")
        }
    }
}
