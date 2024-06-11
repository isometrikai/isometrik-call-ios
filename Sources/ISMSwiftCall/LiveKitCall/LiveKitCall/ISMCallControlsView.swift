//
//  ISMCallControlsView.swift
//  LiveKitCall
//
//  Created by Ajay Thakur on 11/04/24.
//

import Foundation
import UIKit
protocol ISMExpandableCallControlsViewDelegate{
    
    func didToggleTheHeight(isExpanded:Bool)
    func didTapEndCall()
    func didTapMute()
    func didTapSwitchAudioOutput()
    func didTapSwitchCamera()
    func didTapSwitchVideo(turnVideoOn : Bool)
    func didTapDeclineVideoCallRequest()
    func didTapAcceptVideoCallRequest()
    
}


class ISMExpandableCallControlsView: UIView {
    
    let muteButton = UIButton()
    let speaker = UIButton()
    let switchCamera = UIButton()
    let requestTitle = UILabel()
    
    lazy var enableVideoButton : UIButton = {
        let video = UIButton()
        video.setImage(LKCallIcons.videoOff, for: .normal)
        video.heightAnchor.constraint(equalToConstant: 50).isActive = true
     //   video.widthAnchor.constraint(equalToConstant: 50).isActive = true
        video.autoresizesSubviews = true
        video.addTarget(self, action: #selector(setVideoCamera(sender: )), for: .touchUpInside)
        return video
    }()
    
    lazy var videoRequestView : UIView = {
        let requestView = UIView()
        requestTitle.textAlignment = .center
        requestTitle.translatesAutoresizingMaskIntoConstraints = false
        requestView.addSubview(requestTitle)
        
        
        let stackView  = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        requestView.addSubview(stackView)
        
        let declineRequestButton = UIButton()
        declineRequestButton.setTitle("Decline", for: .normal)
        declineRequestButton.layer.cornerRadius = 5
        declineRequestButton.backgroundColor = .red
        declineRequestButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        declineRequestButton.addTarget(self, action: #selector(declineVideoCallRequest(sender: )), for: .touchUpInside)
        
        
        let acceptRequestButton = UIButton()
        acceptRequestButton.setTitle("Switch", for: .normal)
        acceptRequestButton.layer.cornerRadius = 5
        acceptRequestButton.backgroundColor = .green
        acceptRequestButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        acceptRequestButton.addTarget(self, action: #selector(acceptVideoCallRequest(sender: )), for: .touchUpInside)
        
        stackView.addArrangedSubview(declineRequestButton)
        stackView.addArrangedSubview(acceptRequestButton)
        
        
        NSLayoutConstraint.activate([
            requestTitle.topAnchor.constraint(equalTo: requestView.topAnchor, constant: 0),
            requestTitle.leadingAnchor.constraint(equalTo: requestView.leadingAnchor, constant: 0),
            requestTitle.trailingAnchor.constraint(equalTo: requestView.trailingAnchor, constant: 0),
            stackView.topAnchor.constraint(equalTo: requestTitle.bottomAnchor, constant:20),
            stackView.bottomAnchor.constraint(equalTo: requestView.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: requestView.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: requestView.trailingAnchor, constant: 0),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        requestView.isHidden = true
        return requestView
        
    }()
    
    
    lazy var callControlStackView : UIStackView = {
        
        let endCall = UIButton()
        endCall.setImage(LKCallIcons.endCall, for: .normal)
        endCall.heightAnchor.constraint(equalToConstant: 50).isActive = true
      //  endCall.widthAnchor.constraint(equalToConstant: 50).isActive = true
        endCall.autoresizesSubviews = true
        endCall.addTarget(self, action: #selector(endCall(sender: )), for: .touchUpInside)
        
        
        muteButton.setImage(LKCallIcons.microphoneOn, for: .normal)
        muteButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
       // muteButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        muteButton.autoresizesSubviews = true
        muteButton.addTarget(self, action: #selector(muteMicrophone(sender: )), for: .touchUpInside)
        
        speaker.setImage(LKCallIcons.speakerOff, for: .normal)
        speaker.heightAnchor.constraint(equalToConstant: 50).isActive = true
      //  speaker.widthAnchor.constraint(equalToConstant: 50).isActive = true
        speaker.autoresizesSubviews = true
        speaker.isOpaque = true
        speaker.addTarget(self, action: #selector(switchAudioOutput(sender: )), for: .touchUpInside)
        
        switchCamera.setImage(LKCallIcons.switchTheCamera, for: .normal)
        switchCamera.heightAnchor.constraint(equalToConstant: 50).isActive = true
     //   switchCamera.widthAnchor.constraint(equalToConstant: 50).isActive = true
        switchCamera.autoresizesSubviews = true
        switchCamera.isOpaque = true
        switchCamera.addTarget(self, action: #selector(switchCamera(sender: )), for: .touchUpInside)
        switchCamera.isSelected = true
        
        let statckView  = UIStackView(arrangedSubviews: [endCall, muteButton, speaker])
        
        if ISMConfiguration.shared.videoCallOptionEnabled(){
            statckView.addArrangedSubview(enableVideoButton)
            statckView.addArrangedSubview(switchCamera)
        }
        statckView.axis = .horizontal
        statckView.distribution = .fillEqually
        statckView.spacing = 15
        statckView.translatesAutoresizingMaskIntoConstraints = false
        statckView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return statckView
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.up"))
        imageView.tintColor = .white
        return imageView
    }()
    
    private var isExpanded = false
    let expandedHeight: CGFloat = 300
    let collapsedHeight: CGFloat = 150
    var expandableDelegate : ISMExpandableCallControlsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        backgroundColor = .darkGray
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        let controlsActionsStack  = UIStackView(arrangedSubviews: [self.videoRequestView, self.callControlStackView])
        controlsActionsStack.axis = .vertical
        controlsActionsStack.distribution = .fillEqually
        controlsActionsStack.spacing = 10
        
        addSubview(controlsActionsStack)
        
        controlsActionsStack.translatesAutoresizingMaskIntoConstraints = false
        controlsActionsStack.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 15).isActive = true
        controlsActionsStack.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -15).isActive = true
        controlsActionsStack.topAnchor.constraint(equalTo: topAnchor,constant: 50).isActive = true
        
        
//        addSubview(arrowImageView)
//        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
//        arrowImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        arrowImageView.topAnchor.constraint(equalTo: topAnchor,constant: 10).isActive = true
//        arrowImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        arrowImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
//
        // Add tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(arrowTapped))
//        arrowImageView.addGestureRecognizer(tapGesture)
//        arrowImageView.isUserInteractionEnabled = true
        
    }
    
    func updateVideoEnabledStatus(isEnabled :Bool){
        enableVideoButton.isSelected =  isEnabled
        enableVideoButton.setImage(isEnabled ? LKCallIcons.videoOn : LKCallIcons.videoOff , for: .normal)
    }
    
    func updateMuteStatus(isMute :Bool){
        muteButton.setImage(!isMute ? LKCallIcons.microphoneOn : LKCallIcons.microphoneOff , for: .normal)
    }
    func updateSpeakerStatus(isOn :Bool){
        speaker.setImage(isOn ? LKCallIcons.speakerOn : LKCallIcons.speakerOff , for: .normal)
    }
    
    @objc func switchAudioOutput(sender : UIButton){
        self.expandableDelegate?.didTapSwitchAudioOutput()
    }
    
    @objc func muteMicrophone(sender : UIButton){
        self.expandableDelegate?.didTapMute()
    }
    
    @objc func switchCamera(sender : UIButton){
        self.expandableDelegate?.didTapSwitchCamera()
    }
    
    @objc func acceptVideoCallRequest(sender : UIButton){
        updateVideoEnabledStatus(isEnabled:true)
        self.videoRequestView.isHidden = true
        self.callControlStackView.isHidden = false
        self.expandableDelegate?.didTapAcceptVideoCallRequest()
    }
    
    @objc func declineVideoCallRequest(sender : UIButton){
        self.videoRequestView.isHidden = true
        self.callControlStackView.isHidden = false
        self.expandableDelegate?.didTapDeclineVideoCallRequest()
    }
    
    @objc func endCall(sender : UIButton){
        self.expandableDelegate?.didTapEndCall()
    }
    @objc func setVideoCamera(sender : UIButton){
        updateVideoEnabledStatus(isEnabled: !sender.isSelected)
        self.expandableDelegate?.didTapSwitchVideo(turnVideoOn:sender.isSelected)
    }
    
    @objc private func arrowTapped() {
        toggleHeight()
    }
    
    public func videoCallRequestDeclined(){
        self.updateVideoEnabledStatus(isEnabled:false)
        self.videoRequestView.isHidden = true
        self.callControlStackView.isHidden = false
    }
    
    public func receivedRequestToswitchVideoCall(){
        self.videoRequestView.isHidden = false
        self.callControlStackView.isHidden = true
    }
    
    public func switchToVideoCallrequestAccepted(){
        self.videoRequestView.isHidden = true
        self.callControlStackView.isHidden = false
    }
    
    
   private func toggleHeight() {
        isExpanded.toggle()
        UIView.animate(withDuration: 0.3) {
            if self.isExpanded{
                self.frame =
                CGRect(x: 0, y: Int(self.frame.origin.y) - Int(self.collapsedHeight), width: Int(self.bounds.width), height: Int(self.expandedHeight))
                
            }else{
                self.frame = CGRect(x: 0, y: Int(self.frame.origin.y) + Int(self.collapsedHeight) , width: Int(self.bounds.width), height:Int(self.collapsedHeight))
            }
            self.layoutIfNeeded()
            self.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
        
        self.expandableDelegate?.didToggleTheHeight(isExpanded:isExpanded )
    }
    
}
