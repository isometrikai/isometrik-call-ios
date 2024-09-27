//
//  File.swift
//  
//
//  Created by Ajay Thakur on 18/07/24.
//

import Foundation
import AVFAudio
import LiveKit

extension ISMLiveCallView : ISMExpandableCallControlsViewDelegate{
    
    // Turn on speaker
    func turnOnSpeaker() {
        do {
//            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .voiceChat, options: .defaultToSpeaker)
//            try AVAudioSession.sharedInstance().setActive(true)
            
            let session = AVAudioSession.sharedInstance()
                  try session.setPreferredOutputNumberOfChannels(2) // Set number of output channels
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker) // Set preferred output port
                  try session.setActive(true)
            
        } catch {
            print("Error setting audio session category: \(error)")
        }
    }

    // Turn off speaker
    func turnOffSpeaker() {
        do {
            let session = AVAudioSession.sharedInstance()
                  try session.setPreferredOutputNumberOfChannels(2) // Set number of output channels
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.none) // Set preferred output port
                  try session.setActive(true)
        } catch {
            print("Error setting audio session category: \(error)")
        }
    }
    
    func didTapSwitchAudioOutput() {
        
        isSpeakerOn = !isSpeakerOn
        
        
        if isSpeakerOn{
            turnOnSpeaker()
        }else{
            turnOffSpeaker()
        }
        
        Task {
            do {
                AudioManager.shared.isSpeakerOutputPreferred = isSpeakerOn

            }
        }
        
        updateSpeakerStatus()
    }
    
    func didTapDeclineVideoCallRequest() {
        ISMCallManager.shared.publishMessage(message:.requestToSwitchToVideoCallRejected)
        
    }
    
    func didTapAcceptVideoCallRequest() {
        Task {
            do {
                try await  self.room.localParticipant.setCamera(enabled: true)
                self.callType = .VideoCall
                updateParticipantsLayout()
                
            }
        }
        ISMCallManager.shared.publishMessage(message:.requestToSwitchToVideoCallAccepted)
    }
    
    func didToggleTheHeight(isExpanded:Bool) {
        
    }
    
    func didTapEndCall() {
        if ISMCallManager.shared.callIDs.isEmpty{
            ISMCallManager.shared.leaveCall()
        }else{
            
         ISMCallManager.shared.endCall(callUUID: ISMCallManager.shared.callIDs.first ?? UUID())
        }
        self.disconnectCall()
        
    }
    
    func didTapMute() {
        self.isMute = !self.isMute
        updateMuteStatus()
        ISMCallManager.shared.updateMuteStatus(isMute: self.isMute)
    }
    
    func didTapSwitchCamera() {
        guard let trackPublication = room.localParticipant.localVideoTracks.first,
              let videoTrack = trackPublication.track as? LocalVideoTrack,
              let cameraCapturer = videoTrack.capturer as? CameraCapturer else { return }
        
        Task {
            do {
                try await   _ = cameraCapturer.switchCameraPosition()
                
            }
        }
    }
    
    
    func didTapSwitchVideo(turnVideoOn : Bool) {
        
        Task {
            do {
                try await  self.room.localParticipant.setCamera(enabled: turnVideoOn)
                    self.updateParticipantsLayout()
            }
        }
        if callType == .AudioCall, turnVideoOn{
            requestToSwitchToVideoCall()
        }
    }
    
}
