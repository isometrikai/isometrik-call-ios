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


public class ISMCallManager : NSObject{
    
    
    /// hangup the call if no one answered it
    private var callHangupTimer: ISMCallHangupTimer?
    
    var backgroundTaskID : UIBackgroundTaskIdentifier?
    
    var callDetails : ISMMeeting?
    
    var member : ISMCallMember?
    
    var outgoingCallID : UUID?
    
    var callConnectedTime : Date?
    
    
    ///  Check if call is actioned on other device
    var callActiveOnDeviceId : String?
    
    // 1
    public static let shared = ISMCallManager()
    
    
    
    let callController = CXCallController()
    let callObserver = CXCallObserver()
    let audioSession = AVAudioSession.sharedInstance()
    let provider =  CXISMCallManager.shared.provider
    
    // 2
    private(set) var callIDs: [UUID] = []
    
    let viewModel = ISMCallMeetingViewModel()
    
    
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
                ISMLiveCallView.shared.disconnectCall()
            } else {
                print("Call ended successfully")
                
            }
        }
    }
    
}


extension ISMCallManager{
    
    
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
                    ISMCallManager.shared.member = callDetails.members?.first(where: {
                        $0.isAdmin ?? false
                    })
                    if  ISMCallManager.shared.member != nil{
                        ISMCallManager.shared.member?.memberProfileImageURL =  callDetails.initiatorImageUrl
                    }

                }
            })
            
        }
        else {
            // Fallback on earlier versions
        }
    }
    
    /// hangup if  call is not connected within timeInterval seconds
    func scheduleCallHangup() {
        callHangupTimer = ISMCallHangupTimer(timeInterval: ISMConfiguration.shared.getCallHangUpTime(), hangupHandler: hangupCall)
        callHangupTimer?.start()
    }
    
    func cancelHangupTimer() {
           callHangupTimer?.cancel()
     }

       func hangupCall() {
           print("Call is being hung up due to no answer.")
           //Outgoing call
           if let callUUID = self.outgoingCallID {
               self.endCall(callUUID:callUUID)
           }//Incoming call
           else if let callUUID = self.callIDs.first {
               self.endCall(callUUID:callUUID)
               self.rejectCall()
           }
       }
}

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
        if !ISMConfiguration.shared.getUserToken().isEmpty ,let token =  ISMPushKitToken.shared.newToken,   ISMPushKitToken.shared.needToUpdate(){
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
            print("***\(pushPayload)***")
            
            let callDetails = pushPayload
            
            
            let update = CXCallUpdate()
            update.remoteHandle = CXHandle(type: .generic, value: callDetails.initiatorName ?? "")
            
            // 2: Create and set configurations about how the calling application should behave
            
            if #available(iOS 14.0, *) {
                update.hasVideo = callDetails.callType() == .VideoCall
                provider.setDelegate(self, queue: nil)
                let newCall =  UUID()
                provider.reportNewIncomingCall(with:newCall, update: update, completion: { error in
                    if error == nil{
                        
                        if !ISMMQTTManager.shared.hasConnected{
                            ISMMQTTManager.shared.connect(clientId: ISMConfiguration.shared.getUserId())
                        }
                        ISMCallManager.shared.callDetails = callDetails
                        ISMCallManager.shared.publishMessage(message: .callRingingMessage)
                        ISMCallManager.shared.addCall(uuid: newCall)
                        ISMCallManager.shared.member = callDetails.members?.first(where: {
                            $0.isAdmin ?? false
                        })
                        self.scheduleCallHangup()
                        
                        if  ISMCallManager.shared.member != nil{
                            ISMCallManager.shared.member?.memberProfileImageURL =  callDetails.initiatorImageUrl
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
            update.remoteHandle = CXHandle(type: .generic, value: "UNKOWN")
            
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




extension ISMCallManager : CXProviderDelegate{
    
    
    //    func provider(_ provider: CXProvider, execute transaction: CXTransaction) -> Bool {
    //
    //    }
    
    
    
    public func providerDidReset(_ provider: CXProvider) {
        // Stop audio
        // End all calls because they are no longer valid
        // Remove all calls from the app's list of calls
        
        ISMCallManager.shared.removeAllCalls()
    }
    
    // What happens when the user accepts the call by pressing the incoming call button? You should implement the method below and call the fulfill method if the call is successful.
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        // Configure audio session
        // Accept call
        // Notify incoming call accepted
        // &&
        
        
        DispatchQueue.global().async {
            // Request the task assertion and save the ID.
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Finish Network Tasks") {
                // End the task if time expires.
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
            }
            if let id = self.callDetails?.meetingId{
                self.callConnectedTime = Date()
                self.cancelHangupTimer()
                self.callActiveOnDeviceId = ISMDeviceId
                self.viewModel.accpetCall(meetingId: id) { response in
                    guard let rtcToken = response.rtcToken else{
                        self.endCall(callUUID:self.callIDs.first ?? UUID())
                        return
                    }
                    self.pushLiveCallView(rtcToken: rtcToken, meetingID: id, callType: self.callDetails?.callType() ?? .AudioCall)
                }failure: {
                    // If meeting is already Ended
                  //  self.endCall(callUUID:self.callIDs.first ?? UUID())
                }
            }
            // End the task assertion.
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
        
        action.fulfill()
        
        if action.callUUID == ISMCallManager.shared.callIDs.first ?? UUID() && action.isComplete {
            // The call with UUID myCallUUID has been successfully answered
            let answerCallAction = CXAnswerCallAction(call: ISMCallManager.shared.callIDs.first ?? UUID())
            let transaction = CXTransaction(action: answerCallAction)
            
            callController.request(transaction) { error in
                if let error = error {
                    print("Error answering call: \(error.localizedDescription)")
                } else {
                    print("Call answered successfully")
                    
                }
            }
        }
        
        return
    }
    
    // What happens when the user taps the reject button? Call the fail method if the call is unsuccessful. It checks the call based on the UUID. It uses the network to connect to the end call method you provide.
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        
        guard !callObserver.calls.isEmpty else {
            return
        }
        
        if action.callUUID == ISMCallManager.shared.callIDs.first ?? UUID() {
            let endCallAction = CXEndCallAction(call: action.callUUID)
            let transaction = CXTransaction(action: endCallAction)
            
            callController.request(transaction) { error in
                if let error = error {
                    print("CXEndCallAction Error ending call: \(error.localizedDescription)")
                    provider.reportCall(with: action.callUUID, endedAt: Date(), reason: .remoteEnded)
                    return
                } else {
                    print("CXEndCallAction ended successfully")
                }
                DispatchQueue.main.async {
                    ISMLiveCallView.shared.disconnectCall()
                }
                
            }
        }
        
        if let callActiveOnDeviceId = self.callActiveOnDeviceId {
            if callObserver.calls.contains(where: { $0.hasConnected || $0.isOutgoing }) {
                // The call was picked up and then ended
                print("Call was picked up and ended")
                self.leaveCall()
            } else {
                // The call was not connected (e.g., declined before connecting)
                print("Call was declined or ended before connecting")
                self.rejectCall()
            }
        }else{
            self.rejectCall()
        }
        
        ISMCallManager.shared.removeCall(uuid: action.callUUID)
        action.fulfill()
        return
    }
    
    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        
        print("***** CALL ID IN CXStartCallAction \(action.callUUID)")
        // Get call object
        // Configure audio session
        // Add call to ISMCallManager.callIDs
        // Report connection started
        
        // Perform necessary actions for starting an outgoing call
        let handle = action.handle
        // Use the handle to start the call
        ISMCallManager.shared.addCall(uuid: action.callUUID)
        
        // Assume the call is connected after a delay for demonstration purposes
        action.fulfill()
        
    }
    
    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // Called when the provider's audio session is activated
        // Restart any non-call related audio now that the app's audio session has been
        // deactivated after having its priority restored to normal.
    }
    
    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        // Called when the provider's audio session is deactivated
    }
    
    public func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        // Called when an action times out
        print("**Called when an action times out **")
    }
    
    func provider(_ provider: CXProvider, didUpdate call: CXCall) {
        // Called when the call's state changes
        switch call.hasEnded {
        case true:
            print("Call ended")
        case false:
            if call.isOutgoing && call.hasConnected {
                print("Outgoing call connected")
            } else if call.isOutgoing && call.hasEnded {
                print("Outgoing call failed")
            }
        }
    }
    
    
    
    
    public func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // Update holding state
        // Mute the call when it's on hold
        // Stop the video when it's a video call
        
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // Stop/start audio
        if !callIDs.isEmpty{
            ISMLiveCallView.shared.isMute = action.isMuted
            ISMLiveCallView.shared.updateMuteStatus()
        }
        
        action.fulfill()
    }
    
    
    
    func createCall(callUser : ISMCallMember, conversationId : String? = nil, callType : ISMLiveCallType = .AudioCall){
        
        guard canMakeAOutgoingCall(), let memberId = callUser.memberId else{
            return
        }
        self.viewModel.createMeeting(memberId:memberId,conversationId:conversationId,callType: callType) { callDetails in
            
            guard let rtcToken = callDetails.rtcToken, let meetingId = callDetails.meetingId else{
                return
            }
            self.callConnectedTime = nil
            ISMCallManager.shared.member = callUser
            self.reportOutgoingCall(handleName: callUser.memberName ?? callUser.memberIdentifier ?? "",token: rtcToken,meetingId: meetingId, videoEnabled: callType == .VideoCall)
            ISMCallManager.shared.callDetails = callDetails
            ISMCallManager.shared.pushLiveCallView(rtcToken: rtcToken, meetingID: meetingId, callType: callType,isInitiator: true)
        }
    }
    
    
    
    func publishMessage(message : ISMPublishMessageConstants){
        guard let meetingId = callDetails?.meetingId else{
            return
        }
        self.viewModel.publishMessage(meetingId: meetingId, message: message.rawValue){
            print(" Message sent Successfully")
        }
    }
    
    func leaveCall(){
        self.cancelHangupTimer()
        guard  !callIDs.isEmpty, let meetingId = callDetails?.meetingId else{
            return
        }
        self.viewModel.leaveMeeting(meetingId:meetingId){
            self.callActiveOnDeviceId = nil
            self.callConnectedTime = nil
            self.callDetails = nil
            self.member = nil
            self.outgoingCallID = nil
            self.removeAllCalls()
            print("Left Meeting Successfully")
            
        }
    }
    
    func rejectCall(){
        self.cancelHangupTimer()
        guard !callIDs.isEmpty, let meetingId = callDetails?.meetingId else{
            return
        }
        self.viewModel.rejectCall(meetingId:meetingId){_ in
            self.callActiveOnDeviceId = nil
            self.callConnectedTime = nil
            self.callDetails = nil
            self.member = nil
            self.outgoingCallID = nil
            self.removeAllCalls()
            print("Rejected Successfully")
            
        }
    }
    
    func pushLiveCallView(rtcToken: String , meetingID : String, callType: ISMLiveCallType, isInitiator : Bool = false ){
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first else{
                return
            }
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureHandlerForDraggableView))
            panGesture.isEnabled = false
            let liveKit = ISMLiveCallView.shared
            liveKit.configure(frame:window.bounds , rtcToken: rtcToken,meetingId:meetingID,callType: callType, isInitiator: isInitiator)
            liveKit.panGesture = panGesture
            liveKit.addGestureRecognizer(panGesture)
            window.addSubview(liveKit)
        }
    }
    
    @objc func panGestureHandlerForDraggableView(gesture: UIPanGestureRecognizer){
        
        guard let window = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first else{
            return
        }
        let location = gesture.location(in: window)
        let draggedView = gesture.view!
        draggedView.center = location
        
        if gesture.state == .ended {
            if draggedView.frame.midX >= window.layer.frame.width / 2 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    
                    if draggedView.frame.midY >= window.layer.frame.height / 2{
                        draggedView.frame.origin.x = window.frame.width - 160
                        draggedView.frame.origin.y = window.frame.height - (190 + window.safeAreaInsets.bottom)
                    }else{
                        
                        draggedView.frame.origin.x = window.frame.width - 160
                        draggedView.frame.origin.y = window.safeAreaInsets.top + 10
                    }
                    
                }, completion: nil)
            }else{
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    if draggedView.frame.midY >= window.layer.frame.height / 2{
                        draggedView.frame.origin.x = 10
                        draggedView.frame.origin.y = window.frame.height - (160 + window.safeAreaInsets.bottom)
                    }else{
                        
                        draggedView.frame.origin.x = 10
                        draggedView.frame.origin.y = window.safeAreaInsets.top + 10
                    }
                }, completion: nil)
            }
        }
    }
    
    
    func updateMuteStatus(isMute : Bool){
        guard let callId = self.callIDs.first else{
            return
        }
        let muteCallAction = CXSetMutedCallAction(call:callId , muted: isMute)
        let transaction = CXTransaction(action: muteCallAction)
        callController.request(transaction) { error in
            if let error = error {
                print("Error muting call: \(error.localizedDescription)")
            } else {
                print("Call muted successfully")
            }
        }
    }
    
    @objc func handleAudioRouteChange(notification: Notification) {
        // Handle audio route change here
        
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        print("****REASON \(reason)")
        print("****REASON VAlue \(reasonValue)")
        switch reason {
            
        case .categoryChange, .override:
            // Speaker has changed, handle accordingly
            if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription,
               let outputs = previousRoute.outputs.first {
                
                print("****\(outputs)")
                if outputs.portType == .builtInSpeaker,ISMLiveCallView.shared.isSpeakerOn{
                    switchToReceiver()
                    
                } else if outputs.portType == .builtInReceiver,!ISMLiveCallView.shared.isSpeakerOn {
                    switchToSpeaker()
                }
            }
        default:
            break
        }
    }
    
    func switchToSpeaker() {
        
        guard !ISMLiveCallView.shared.isSpeakerOn else {
            return
        }
        ISMLiveCallView.shared.isSpeakerOn = true
        ISMLiveCallView.shared.updateSpeakerStatus()
    }
    
    func switchToReceiver() {
        guard ISMLiveCallView.shared.isSpeakerOn else {
            return
        }
        ISMLiveCallView.shared.isSpeakerOn = false
        ISMLiveCallView.shared.updateSpeakerStatus()
    }
    
    
}



@available(iOS 14.0, *)
class CXISMCallManager: NSObject {
    static let shared = CXISMCallManager()
    
    let provider: CXProvider
    
    override init() {
        self.provider = CXProvider.default
        super.init()
    }
    
}

@available(iOS 14.0, *)
extension CXProvider {
    static var `default`: CXProvider {
        let config = CXProviderConfiguration.default
        return CXProvider(configuration: config)
    }
}



extension CXProviderConfiguration {
    // The app's provider configuration, representing its CallKit capabilities
    @available(iOS 14.0, *)
    static var `default`: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration()
        providerConfiguration.iconTemplateImageData = UIImage(systemName: "globe").flatMap { $0.pngData() }
        providerConfiguration.supportsVideo = true
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.supportedHandleTypes = [.generic]
        providerConfiguration.includesCallsInRecents = true
        providerConfiguration.ringtoneSound = "Ringing.mp3"
        
        return providerConfiguration
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
