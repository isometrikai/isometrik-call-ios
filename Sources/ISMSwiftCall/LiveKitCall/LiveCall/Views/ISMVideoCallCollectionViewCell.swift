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
    
    public let callStatus = UILabel()
    public let name =  UILabel()
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
                addVideoView()
                
            }
            
            if let participant {
                // listen to events
                participant.add(delegate: self)
                videoView.track = nil
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
        videoView.setNeedsLayout()
    }
    
    private func setFirstVideoTrack() {
        let track = participant?.mainVideoTrack
        videoView.track = track
    }
    
    override init(frame: CGRect) {
        Self.instanceCounter += 1
        cellId = Self.instanceCounter
        super.init(frame: frame)
        addVideoView()
        
        name.text = ""
        name.textColor = .white
        name.font = .boldSystemFont(ofSize: 30)
        name.textAlignment = .center
        
        callStatus.text = ""
        callStatus.textColor = .white
        name.font = .systemFont(ofSize: 20)
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
    
    func setDetails(name : String?, status : ISMCallStatus){
        self.name.isHidden = name == nil
        self.callStatus.isHidden = status == .started
        self.callStatus.text = status.rawValue
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



class ProfileView: UIView {

    let topSpaceView = UIView()
    let nameLabel = UILabel()
    let timerLabel = UILabel()
    let profileImageView = UIImageView()
    var stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        stackView = UIStackView(arrangedSubviews: [topSpaceView,profileImageView, nameLabel, timerLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        topSpaceView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        nameLabel.textAlignment = .center
        timerLabel.textAlignment = .center
        
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
    }
}
