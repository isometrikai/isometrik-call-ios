//
//  ISMLiveCallView.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 06/03/24.
//


import UIKit
import LiveKit
import AVFoundation

class ISMLiveCallView: UIView, ISMCustomNavigationBarDelegate, AppearanceProvider {
    
    private var remoteParticipants = [Participant]()
    var customNavBar : ISMCustomNavigationBar?
    var callType : ISMLiveCallType = .AudioCall
    var timer : Timer?
    var shouldUpdateCameraStatus : Bool = false
    let room  = Room()
    var rtcToken : String
    var meetingId : String?
    var callStatus : ISMCallStatus?
    var isMute : Bool = false
    var isSpeakerOn : Bool = false
    var panGesture :  UIPanGestureRecognizer?
    var isMinimised : Bool?
    
    //Padding for floatingview bounds
    let padding = 10.0
    
    /// Set a flag for sending a video call Request, to avoid  sending multiple requests
    lazy var isVideoCallRequestSent : Bool = false
    
    var audioPlayer: AVAudioPlayer?
    
    
    func didTapBackButton() {
        guard let window = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first else{
            return
        }
        isMinimised = true
        customNavBar?.isHidden = true
        panGesture?.isEnabled = true
        DispatchQueue.main.async {
            self.tapGestureForDraggableView.isEnabled = false
            self.panGestureForDraggableView.isEnabled = false
            self.expandableView.isHidden = true
            self.layer.cornerRadius = 5
            self.clipsToBounds = true
            UIView.animate(withDuration: 0.5) {
                self.frame = CGRect(x: window.frame.width - 160, y: window.frame.height - (190 + window.safeAreaInsets.bottom), width: 150, height: 180)
                self.autoresizesSubviews = true
                self.layoutSubviews()
                self.layoutIfNeeded()
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
            
            
        }
        
    }
    
    private static var privateShared: ISMLiveCallView?
    
    static var shared: ISMLiveCallView {
        if privateShared == nil {
            privateShared = ISMLiveCallView()
        }
        return privateShared!
    }
    
    func configure( frame : CGRect, rtcToken: String, meetingId : String? = nil,callType : ISMLiveCallType = .AudioCall, isInitiator : Bool) {
        self.rtcToken = rtcToken
        self.meetingId = meetingId
        self.callType = callType
        self.callStatus = isInitiator ? .calling : nil
        self.frame = frame
        
        self.backgroundColor = .black
        UIApplication.shared.isIdleTimerDisabled = true
        collectionView.dataSource = self
        
        customNavBar = ISMCustomNavigationBar(frame: CGRect(x: 0, y: window?.safeAreaInsets.top ?? 44, width: self.frame.width, height: 64))
        if let customNavBar{
            customNavBar.delegate = self
            customNavBar.titleLabel.text = "End-to-End-Encrypted"
            insertSubview(customNavBar, aboveSubview: collectionView)
        }
        self.addCallControls()
        
        //        insertSubview(ConnectingLabel, aboveSubview: collectionView)
        //        NSLayoutConstraint.activate([
        //            ConnectingLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        //            ConnectingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        //        ])
        
        room.add(delegate: self)
        if self.callType == .AudioCall{
            Task {
                do {
                    AudioManager.shared.isSpeakerOutputPreferred = false
                }
            }
        }
        self.connect()
        
        
    }
    
    private init( frame : CGRect, rtcToken: String, meetingId : String? = nil) {
        self.rtcToken = rtcToken
        self.meetingId = meetingId
        super.init(frame: frame)
    }
    
    private override init(frame: CGRect) {
        self.rtcToken = ""
        self.meetingId = nil
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let videoView = floatingVideoView(){
            let size = min(frame.width, frame.height) * 0.3
            videoView.frame = CGRect(x:self.bounds.width - (size + padding) , y: self.bounds.height - (size + self.expandableView.collapsedHeight + padding), width: size, height: size)
        }
    }
    
    static func reset() {
        privateShared = nil
        privateShared = nil
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    lazy var collectionView: ISMLiveCallCollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let cv = ISMLiveCallCollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.delegate = self
        cv.register(ISMLiveCallCollectionViewCell.self, forCellWithReuseIdentifier: "ISMLiveCallCollectionViewCell")
        cv.register(ISMAudioCallCollectionViewCell.self, forCellWithReuseIdentifier: "ISMAudioCallCollectionViewCell")
        cv.contentInsetAdjustmentBehavior = .never
        
        self.addSubview(cv)
        return cv
    }()
    
    
    
    var keepLocalAsFocusParticipant : Bool = false
    
    var localParticipant : LocalParticipant? {
        
        didSet{
            DispatchQueue.main.async {
                self.updateParticipantsLayout()
                self.collectionView.reloadData()
            }
        }
    }

    
    
    
    
    lazy var focusVideoPausedImageView : UIImageView = {
        let videoPausedImageView = UIImageView()
        videoPausedImageView.image = #imageLiteral(resourceName: "profile_avatar")
        videoPausedImageView.contentMode = .scaleAspectFill
        videoPausedImageView.clipsToBounds = true
        videoPausedImageView.autoresizesSubviews = true
        videoPausedImageView.backgroundColor = .black
        
        return videoPausedImageView
    }()
    
    lazy var draggableVideoPausedImageView : UIImageView = {
        let videoPausedImageView = UIImageView()
        videoPausedImageView.image = #imageLiteral(resourceName: "profile_avatar")
        videoPausedImageView.contentMode = .scaleAspectFit
        videoPausedImageView.clipsToBounds = true
        videoPausedImageView.autoresizesSubviews = true
        videoPausedImageView.backgroundColor = .black
        return videoPausedImageView
    }()
    
    lazy var focusMemberNameLabel : UILabel = {
        let name = UILabel()
        name.text = ""
        return name
    }()
    
    lazy var draggableMemberNameLabel : UILabel = {
        let name = UILabel()
        name.text = ""
        name.font = UIFont.systemFont(ofSize: 10)
        name.numberOfLines = 0
        return name
    }()
    
    
    
    lazy var placeholderForFocusedView : UIView = {
        let videoPaused = UIView()
        videoPaused.backgroundColor = .black
        videoPaused.addSubview(self.focusVideoPausedImageView)
        videoPaused.addSubview(self.focusMemberNameLabel)
        self.focusVideoPausedImageView.translatesAutoresizingMaskIntoConstraints = false
        self.focusMemberNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.focusVideoPausedImageView.widthAnchor.constraint(equalToConstant: 300),
            self.focusVideoPausedImageView.heightAnchor.constraint(equalToConstant: 300),
            
            self.focusVideoPausedImageView.centerXAnchor.constraint(equalTo: videoPaused.centerXAnchor),
            self.focusVideoPausedImageView.centerYAnchor.constraint(equalTo: videoPaused.centerYAnchor),
            
            self.focusMemberNameLabel.centerXAnchor.constraint(equalTo: self.focusVideoPausedImageView.centerXAnchor),
            self.focusMemberNameLabel.topAnchor.constraint(equalTo: self.focusVideoPausedImageView.bottomAnchor, constant: 20)
            
        ])
        
        videoPaused.clipsToBounds = true
        return videoPaused
    }()
    
    lazy var placeholderForDraggableView : UIView = {
        let videoPaused = UIView()
        videoPaused.backgroundColor = .black
        videoPaused.layer.cornerRadius = 3
        videoPaused.clipsToBounds = true
        videoPaused.layer.borderWidth = 0.2
        videoPaused.layer.borderColor = UIColor.gray.cgColor
        
        let videoPausedImageView = UIImageView()
        videoPausedImageView.image = #imageLiteral(resourceName: "profile_avatar")
        videoPausedImageView.contentMode = .scaleAspectFit
        videoPausedImageView.clipsToBounds = true
        
        videoPaused.addSubview(self.draggableVideoPausedImageView)
        videoPaused.addSubview(self.draggableMemberNameLabel)
        self.draggableVideoPausedImageView.translatesAutoresizingMaskIntoConstraints = false
        self.draggableMemberNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.draggableVideoPausedImageView.widthAnchor.constraint(equalToConstant: 50),
            self.draggableVideoPausedImageView.heightAnchor.constraint(equalToConstant: 50),
            
            self.draggableVideoPausedImageView.centerXAnchor.constraint(equalTo: videoPaused.centerXAnchor),
            self.draggableVideoPausedImageView.centerYAnchor.constraint(equalTo: videoPaused.centerYAnchor),
            
            self.draggableMemberNameLabel.centerXAnchor.constraint(equalTo: self.draggableVideoPausedImageView.centerXAnchor),
            self.draggableMemberNameLabel.topAnchor.constraint(equalTo: self.draggableVideoPausedImageView.bottomAnchor, constant: 5)
            
        ])
        return videoPaused
    }()
    
    
    
    
    
    
    private let expandableView: ISMExpandableCallControlsView = {
        let view = ISMExpandableCallControlsView()
        return view
    }()
    
    
    
    
    lazy var panGestureForDraggableView : UIPanGestureRecognizer = {
        
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(handlePanGestureForDraggableView(gesture:)))
        return panGesture
        
    }()
    
    
    lazy var tapGestureForDraggableView: UITapGestureRecognizer = {
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(handleTapGestureForDraggableView(gesture:)))
        
        return tapGesture
        
    }()
    
    
    
    
    
    
    
    @objc func updateCameraStatus(){
        if shouldUpdateCameraStatus{
            Task{
                try await  self.room.localParticipant.setCamera(enabled: true)
            }
        }else{
            return
        }
        
        if self.room.localParticipant.isCameraEnabled(){
            shouldUpdateCameraStatus = false
        }
    }
    
    
    /*Request user to switch to to the video call*/
    func requestToSwitchToVideoCall(){
        ISMCallManager.shared.publishMessage(message: .requestToSwitchToVideoCall)
    }
    
    
    func updateMuteStatus(){
        Task {
            do {
                try await  room.localParticipant.setMicrophone(enabled: !self.isMute)
                
            }
        }
        self.expandableView.updateMuteStatus(isMute: self.isMute)
    }
    
    
    func updateSpeakerStatus(){
        
        self.expandableView.updateSpeakerStatus(isOn: isSpeakerOn)
    }
    
    
    func playAudio(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.soloAmbient)
              try audioSession.setActive(true)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        
        if !appearance.soundFiles.ringer.isEmpty {
        
            
            let url = URL(fileURLWithPath: appearance.soundFiles.ringer)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 /* -1 means infinite loop*/
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }else{
            print("PATH : is Nill")
        }
    }
    
    func stopAudio(){
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    
    
    
    
    func connect(){
        let connectOptions = ConnectOptions(
            autoSubscribe: true /* don't autosubscribe if publish mode*/
        )
        
        let roomOptions = RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(
                dimensions: .h1080_169
            ),
            defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(
                dimensions: .h1080_169,
                useBroadcastExtension: true
            ),
            defaultVideoPublishOptions: VideoPublishOptions(
                simulcast:  false
            ),
            adaptiveStream: true,
            dynacast: true,
            e2eeOptions: nil
        )
        
        Task {
            do {
                try await room.connect(url: ISMConfiguration.shared.getIsometrikLiveStreamUrl(), token: rtcToken,connectOptions: connectOptions,roomOptions: roomOptions)
                /* Publish camera & mic*/
                try await room.localParticipant.setMicrophone(enabled: true)
                try await room.localParticipant.setCamera(enabled: callType != .AudioCall)
                
            } catch {
                print("Failed to connect: \(error)")
            }
        }
    }
    
    
    func disconnectCall(){
        guard ISMLiveCallView.privateShared != nil else {
            return
        }
        stopAudio()
        Task {
            do {
                await room.disconnect()
            }
        }
        DispatchQueue.main.async {
            self.timer?.invalidate()
            UIApplication.shared.isIdleTimerDisabled = false
            self.removeFromSuperview()
            ISMLiveCallView.reset()
        }
        
    }
    
    
    
    func maximiseTheView(){
        guard isMinimised ?? false, let window = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first else{
            return
        }
        panGesture?.isEnabled = false
        customNavBar?.isHidden = false
        DispatchQueue.main.async {
            self.tapGestureForDraggableView.isEnabled = true
            self.panGestureForDraggableView.isEnabled = true
            UIView.animate(withDuration: 0.5) {
                self.frame = window.bounds
                self.collectionView.collectionViewLayout.invalidateLayout()
            }completion: { isCompleted in
                self.layoutSubviews()
                self.layoutIfNeeded()
            }
            self.layer.cornerRadius = 0
            self.clipsToBounds = true
            self.expandableView.isHidden = false
            self.expandableView.superview?.bringSubviewToFront(self.expandableView)
        }
        
    }
    
    @objc func handlePanGestureForDraggableView(gesture: UIPanGestureRecognizer){
        
        
        guard let draggableView = floatingVideoView() else{
            return
        }
        let location = gesture.location(in: self)
        let view = gesture.view
        view?.center = location
        
        // Size of floating video view
        let size = min(self.frame.width, self.frame.height) * 0.3
 
        
        if gesture.state == .ended {
            if draggableView.frame.midX >= self.layer.frame.width / 2 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    
                    draggableView.frame.origin.x = self.bounds.width - (size + self.padding)
                    
                    if draggableView.frame.midY >= self.layer.frame.height / 2{
                        draggableView.frame.origin.y = self.layer.frame.height - (size + self.expandableView.collapsedHeight + self.padding)
                    }else{
                        draggableView.frame.origin.y = self.safeAreaInsets.top + (self.customNavBar?.bounds.height ?? 10)
                    }
                    
                }, completion: nil)
            }else{
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    draggableView.frame.origin.x = 10
                    if draggableView.frame.midY >= self.layer.frame.height / 2{
                        draggableView.frame.origin.y = self.layer.frame.height - (size + self.expandableView.collapsedHeight + self.padding)
                    }else{
                        draggableView.frame.origin.y = self.safeAreaInsets.top + (self.customNavBar?.bounds.height ?? 10)
                    }
                }, completion: nil)
            }
            
        }
    }
    
    
    @objc func handleTapGestureForDraggableView(gesture: UITapGestureRecognizer){
        
        DispatchQueue.main.async { [self] in
            keepLocalAsFocusParticipant  = !keepLocalAsFocusParticipant
            updateParticipantsLayout()
        }
        
    }
    
    
    
    
    
    func addCallControls(){
        DispatchQueue.main.async { [self] in
            expandableView.frame =  CGRect(x: 0, y: self.bounds.height - expandableView.collapsedHeight, width: self.bounds.width, height: expandableView.collapsedHeight)
            expandableView.configureView()
            expandableView.expandableDelegate = self
            expandableView.updateVideoEnabledStatus(isEnabled: callType == .VideoCall)
            addSubview(expandableView)
        }
    }
    
    
    func sortedParticipants() -> [Participant] {
        room.allParticipants.values.sorted { p1, p2 in
            if p1 is LocalParticipant { return true }
            if p2 is LocalParticipant { return false }
            return (p1.joinedAt ?? Date()) < (p2.joinedAt ?? Date())
        }
    }
    
    
    
    func updateParticipantsLayout(){
        remoteParticipants = room.allParticipants.values.filter {
            return $0.identity != localParticipant?.identity
        }
        
        updateTheFloatingParticipant(remotePaticipants:remoteParticipants)
        
        if  room.remoteParticipants.isEmpty || keepLocalAsFocusParticipant{
            remoteParticipants =  [room.localParticipant]
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    func updateCallStatus(_ callStatus : ISMCallStatus){
        self.callStatus = callStatus
        self.updateParticipantsLayout()
    }
    
    func showTheVideoCallRequest(meeting : ISMMeeting){
        
        DispatchQueue.main.async {
            self.expandableView.receivedRequestToswitchVideoCall()
            self.expandableView.requestTitle.text = "\(meeting.senderName ?? "User") is requesting to switch to video call..."
        }
    }
    
    func switchToVideoCallrequestAccepted(){
        self.expandableView.switchToVideoCallrequestAccepted()
        
        Task {
            do {
                try await  self.room.localParticipant.setCamera(enabled: true)
                self.callType = .VideoCall
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            }
        }
    }
    
    func videoCallRequestDeclined(){
        
        DispatchQueue.main.async {
            self.expandableView.videoCallRequestDeclined()
        }
    }
    
    
    
    func participantUpdated(participant : Participant){
        
        updateParticipantsLayout()
    }
    
    func updateTheFloatingParticipant(remotePaticipants:[Participant]){
        DispatchQueue.main.async {
            guard self.callType == .VideoCall, remotePaticipants.count == 1 else{
                self.floatingVideoView()?.removeFromSuperview()
                return
            }
            
            
            self.floatingVideoView()?.removeFromSuperview()
            self.addFloatingVideoView()
            if self.keepLocalAsFocusParticipant{
                self.floatingVideoView()?.track = remotePaticipants.first?.mainVideoTrack
            }else{
                self.floatingVideoView()?.track = self.room.localParticipant.mainVideoTrack
            }
            
        }
        
        
        
    }
    
    func addFloatingVideoView(){
        let floatingVideoView = VideoView()
        floatingVideoView.layoutMode = .fill
        floatingVideoView.layer.cornerRadius = 3
        floatingVideoView.clipsToBounds = true
        floatingVideoView.isHidden = false
        floatingVideoView.backgroundColor = .black
        floatingVideoView.translatesAutoresizingMaskIntoConstraints = false
        
        self.insertSubview(floatingVideoView, aboveSubview: self.collectionView)
        floatingVideoView.addGestureRecognizer(panGestureForDraggableView)
        floatingVideoView.addGestureRecognizer(tapGestureForDraggableView)
        self.layoutSubviews()
        self.layoutIfNeeded()
    }
    
    
    /// To get the floading video view if it is added in view
    /// - Returns: vfloatimg video view instance
    func floatingVideoView() -> VideoView?{
        return self.subviews.first {
            $0.isKind(of: VideoView.self)
        } as? VideoView
    }
    
}


extension ISMLiveCallView : ISMExpandableCallControlsViewDelegate{
    func didTapSwitchAudioOutput() {
        
        isSpeakerOn = !isSpeakerOn
        
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
        
        ISMCallManager.shared.endCall(callUUID: ISMCallManager.shared.callIDs.first ?? UUID())
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
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            }
        }
        if callType == .AudioCall, turnVideoOn{
            requestToSwitchToVideoCall()
        }
    }
    
}


extension ISMLiveCallView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /* Implement required methods for UICollectionViewDataSource and UICollectionViewDelegateFlowLayout*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /* Return the number of items in your collection view*/
        
        if remoteParticipants.isEmpty && callType == .AudioCall{
            return 1
        }
        return remoteParticipants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let callStatus{
            if callStatus == .started{
                stopAudio()
                
            }else if callStatus == .calling || callStatus == .ringing {
                stopAudio()
                self.playAudio()
                
            }
        }
        
        
        if callType == .AudioCall{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ISMAudioCallCollectionViewCell", for: indexPath) as! ISMAudioCallCollectionViewCell
            cell.configure(withName: ISMCallManager.shared.member?.memberName ??   ISMCallManager.shared.member?.memberIdentifier ?? "Unknown", profileImageUrl: ISMCallManager.shared.member?.memberProfileImageURL , status: self.callStatus)
            return cell
        }else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ISMLiveCallCollectionViewCell", for: indexPath) as! ISMLiveCallCollectionViewCell
            let participant = remoteParticipants[indexPath.row]
            cell.participant = participant
            cell.setDetails(name:ISMCallManager.shared.member?.memberName ??   ISMCallManager.shared.member?.memberIdentifier ?? "Unknown" , status: self.callStatus ?? .calling)
            return cell
        }
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = self.frame
        /* Return the size of each item in your collection view*/
        return CGSize(width: screenSize.width, height: screenSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        maximiseTheView()
    }
}








protocol ISMCustomNavigationBarDelegate {
    func didTapBackButton()
}





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
        
    }
    
    
    func room(_ room: Room, participant: RemoteParticipant?, didReceiveData data: Data, forTopic topic: String) {
        
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didUnsubscribeTrack publication: RemoteTrackPublication) {
        
    }
    
    func room(_ room: Room, didUpdateConnectionState connectionState: ConnectionState, from oldValue: ConnectionState) {
        if connectionState == .connected{
            
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
                
                //                guard let trackPublication = room.localParticipant.localVideoTracks.first,
                //                 let videoTrack = trackPublication.track as? LocalVideoTrack else { return }
                
            }
        }
    }
    
    func room(_ room: Room, participantDidConnect participant: RemoteParticipant) {
        
        guard  participant.id != room.localParticipant.id else{
            return
        }
        DispatchQueue.main.async {
            switch self.callType{
            case .AudioCall, .VideoCall :
                self.updateCallStatus(.started)
                self.participantUpdated(participant: participant)
            case .GroupCall  :
                self.showToast(message: "\(participant.name ?? "") has joined the meeting.", duration: 2.0)
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
                self.showToast(message: "\(String(describing: participant.name)) has left the meeting.", duration: 2.0)
            }
            
        }
        
    }
    
    func room(_ room: Room, participant localParticipant: LocalParticipant, didPublishTrack publication: LocalTrackPublication) {
        self.localParticipant = localParticipant
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didSubscribeTrack publication: RemoteTrackPublication) {
        switch self.callType{
        case .AudioCall :
            self.callStatus = .started
            self.participantUpdated(participant: participant)
        case .GroupCall , .VideoCall :
            self.callStatus = .started
            self.participantUpdated(participant: participant)
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




