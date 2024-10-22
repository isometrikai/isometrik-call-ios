//
//  File.swift
//  
//
//  Created by Ajay Thakur on 12/07/24.
//

import Foundation
import LiveKit


extension ISMLiveCallView : RoomDelegate{
    
    func room(_ room: Room, didUpdateIsRecording isRecording: Bool) {
        
    }
    
    func room(_ room: Room, didUpdateSpeakingParticipants speakers: [Participant]) {
    }
    
    func room(_ room: Room, participant: Participant, didUpdatePermissions permissions: ParticipantPermissions) {

    }
    
    func room(_ room: Room, participant: RemoteParticipant, didPublishTrack publication: RemoteTrackPublication) {
        
    }
    func room(_ room: Room, participant: RemoteParticipant, didUnpublishTrack publication: RemoteTrackPublication) {
        
    }
    func room(_ room: Room, participant: Participant, trackPublication publication: TrackPublication, didUpdateIsMuted muted: Bool) {
        self.updateParticipantsLayout()
    }
    
    
    func room(_ room: Room, participant: RemoteParticipant?, didReceiveData data: Data, forTopic topic: String) {
        
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didUnsubscribeTrack publication: RemoteTrackPublication) {
        
    }
    
    func room(_ room: Room, didUpdateConnectionState connectionState: ConnectionState, from oldValue: ConnectionState) {
        switch connectionState {
        case .connected:
            
            if callStatus == .reconnecting {
                
                if oldValue == .connecting{
                    self.updateParticipantsLayout()
                }
                return
            }
                
                // On background to foreground sometime camera freez, to update it switch camera status
                if oldValue == .connecting, self.callType == .VideoCall{
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCameraStatus), userInfo: nil, repeats: true)
                }
                
                if oldValue == .reconnecting{
                    self.localParticipant = self.room.localParticipant
                    DispatchQueue.main.async {
                        if self.callType == .VideoCall{
                            self.shouldUpdateCameraStatus = true
                        }
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
        case .reconnecting :
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        default:
           break
        }
      
      
    }
    
    func room(_ room: Room, participantDidConnect participant: RemoteParticipant) {
        
        guard  participant.id != room.localParticipant.id else{
            return
        }
        self.participantUpdated(participant: participant)
        
        DispatchQueue.main.async {
            switch self.callType{
            case .AudioCall, .VideoCall :
                self.updateCallStatus(.started)
            
            case .GroupCall  :
                self.showToast(message: "\(participant.name ?? "Someone") has joined the meeting.", duration: 2.0)
                
            case .none:
                break
            }
            
        }
    }
    
    func room(_ room: Room, participantDidDisconnect participant: RemoteParticipant) {

        self.participantUpdated(participant: participant)
        
        switch callType{
        case .AudioCall,.VideoCall :
            self.disconnectCall()
            if let callID = ISMCallManager.shared.callIDs.first{
                ISMCallManager.shared.endCall(callUUID: callID)
            }
        case .GroupCall  :
            DispatchQueue.main.async {
                self.showToast(message: "\(participant.name ?? "Someone") has left the meeting.", duration: 2.0)
            }
            
        case .none:
            break
        }
        
    }
    
    func room(_ room: Room, participant localParticipant: LocalParticipant, didPublishTrack publication: LocalTrackPublication) {
        self.localParticipant = localParticipant
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didSubscribeTrack publication: RemoteTrackPublication) {
        updateHeaderStatus()
        switch self.callType{
        case .AudioCall :
            self.callStatus = .started
            self.participantUpdated(participant: participant)
        case .GroupCall , .VideoCall :
            self.callStatus = .started
            self.participantUpdated(participant: participant)
        case .none:
            break
        }
    }
    
    
    
    
    private func room(_ room: Room, didFailToConnectWithError error: Error) {
        print("ERROR : \(error.localizedDescription)")
    }
    
    
}
extension Participant {
    
    public var mainVideoPublication: TrackPublication? {
        firstScreenSharePublication ?? firstCameraPublication
    }
    
    public var mainVideoTrack: VideoTrack? {
        firstScreenShareVideoTrack ?? firstCameraVideoTrack
    }
    
    public var subVideoTrack: VideoTrack? {
        firstScreenShareVideoTrack != nil ? firstCameraVideoTrack : nil
    }
    
    public var mainAudoTrack: AudioTrack? {
        firstAudioTrack
    }
    
}
