//
//  File.swift
//  
//
//  Created by Ajay Thakur on 10/07/24.
//

import Foundation
import UIKit
import LiveKit

class ISMLiveCallCollectionViewCell: UICollectionViewCell {
    
    var status : ISMCallStatus?
    let profileView = ProfileView()
    public let callStatus = UILabel()
    public var name =  UILabel()
    public static var instanceCounter: Int = 0
    public let cellId: Int
    
    public var videoView: VideoView = {
        let r = VideoView()
        r.layoutMode = .fit
        r.backgroundColor = .darkGray
        r.clipsToBounds = true
        r.isDebugMode = false
        return r
    }()
    
    public let userDetailsStackView: UIStackView = {
        let r = UIStackView()
        r.backgroundColor = .clear
        r.axis = .vertical
        r.distribution = .equalSpacing
        r.spacing = 5
        r.translatesAutoresizingMaskIntoConstraints = false
        return r
    }()
    
    var hideDetails : Bool = true {
        didSet{
            self.userDetailsStackView.isHidden = hideDetails
        }
    }
    
    
    // weak reference to the Participant
    public weak var participant: Participant? {
        didSet {
            guard oldValue != participant else { return }
            
            if let oldValue {
                // un-listen previous participant's events
                // in case this cell gets reused.
                oldValue.remove(delegate: self)
                videoView.track = nil
                videoView.removeFromSuperview()
            }
            
            if let participant {
                // listen to events
                participant.add(delegate: self)
              //  videoView.track = nil
                setFirstVideoTrack()
                // make sure the cell will call layoutSubviews()
                setNeedsLayout()
            }
        }
    }
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Self.instanceCounter -= 1
        
        print("\(String(describing: self)) deinit, instances: \(Self.instanceCounter)")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("prepareForReuse, cellId: \(cellId)")
        
        participant = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoView.frame = contentView.bounds
        profileView.frame = contentView.bounds
        self.profileView.topSpaceView.isHidden = self.bounds.size.height < 200
        self.profileView.timerLabel.isHidden = self.bounds.size.height < 200
        videoView.setNeedsLayout()
    }
    
    private func setFirstVideoTrack() {
        if let track = participant?.mainVideoTrack{
            addVideoView()
            videoView.track = track
            profileView.isHidden = true
            self.bringSubviewToFront(videoView)
        }else if  status == .started {
           
            videoView.track = nil
            profileView.isHidden = false
            var memberName : String = "Unknown"
                if let member = ISMCallManager.shared.members?.first(where: {
                    $0.memberId == participant?.identity?.stringValue
                }){
                    memberName = member.memberName ?? "Unknown"
                }
            
            profileView.profileImageView.setImage(urlString:"",placeholderImage: CircularImagePlaceholder.createCircularInitialsPlaceholder(name:  memberName, size: CGSize(width:profileView.profileImageView.bounds.width , height: profileView.profileImageView.bounds.height)))
            self.bringSubviewToFront(profileView)
        }
        self.layoutSubviews()
    }
    
    override init(frame: CGRect) {
        Self.instanceCounter += 1
        cellId = Self.instanceCounter
        super.init(frame: frame)
        self.addProfileView()
        addVideoView()
        
        
        name.text = ""
        name.textColor = .white
        name.font = .boldSystemFont(ofSize: 40)
        name.textAlignment = .center
        
        callStatus.text = ""
        callStatus.textColor = .white
        name.font = .boldSystemFont(ofSize: 20)
        callStatus.textAlignment = .center
        
        userDetailsStackView.addArrangedSubview(name)
        userDetailsStackView.addArrangedSubview(callStatus)
        addSubview(userDetailsStackView)
        NSLayoutConstraint.activate([
            userDetailsStackView.topAnchor.constraint(equalTo: self.topAnchor,constant: 150),
            userDetailsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            userDetailsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
        
        contentView.backgroundColor = UIColor.black
        contentView.layer.cornerRadius = 8.0
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.clipsToBounds = true
        
    }
    
    func addVideoView(){
        videoView = VideoView.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        videoView.layoutMode = .fill
        contentView.addSubview(videoView)
    }
    
    func addProfileView(){
        profileView.frame = bounds
        profileView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(profileView)
    }
    func setDetails(member: ISMCallMember?,status: ISMCallStatus?){
        if status == .reconnecting{
            self.callStatus.text =  "Reconnecting..."
        }else{
            self.callStatus.text = status?.rawValue
        }
        self.name.text = member?.memberName
        self.hideDetails = status == .started
        self.bringSubviewToFront(self.userDetailsStackView)

    }
    
    func showGroupCalling(groupName:String?,status: ISMCallStatus? ){
        self.callStatus.isHidden = status == .started
        self.name.text = groupName
        self.callStatus.text = status?.rawValue
        self.hideDetails = status == .started
    }
    
}

extension ISMLiveCallCollectionViewCell: ParticipantDelegate {
    func participant(_: RemoteParticipant, didSubscribeTrack _: RemoteTrackPublication) {
        print("didSubscribe")
        DispatchQueue.main.async { [weak self] in
            self?.setFirstVideoTrack()
        }
    }
    
    func participant(_: RemoteParticipant, didUnsubscribeTrack _: RemoteTrackPublication) {
        print("didUnsubscribe")
        DispatchQueue.main.async { [weak self] in
            self?.setFirstVideoTrack()
        }
    }
}


