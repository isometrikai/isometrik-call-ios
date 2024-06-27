//
//  ISMCallCollectionView.swift
//  LiveKitCall
//
//  Created by Ajay Thakur on 11/04/24.
//

import Foundation
import UIKit
import LiveKit


class ISMLiveCallCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update cell frames here
        for indexPath in indexPathsForVisibleItems {
            if let cell = cellForItem(at: indexPath) as? ISMLiveCallCollectionViewCell {
                let updatedFrame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.size.width, height: cell.frame.size.height)
                cell.frame = updatedFrame
                cell.videoView.frame = updatedFrame
            }
        }
    }
}





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
        layer.cornerRadius = 8.0
    }
    
    func addVideoView(){
        videoView = VideoView.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        videoView.layoutMode = .fill
        contentView.addSubview(videoView)
    }
    
    func setDetails(name : String?, status : ISMCallStatus){
        self.name.isHidden = name == nil
        self.callStatus.isHidden = status == .started
        self.name.text = name
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


class ISMAudioCallCollectionViewCell: UICollectionViewCell {
    
    let profileView = ProfileView()
    
    var startTime : Date?
    var timer: Timer?
    var seconds: Int = 0
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Adjust the views inside the cell
        self.profileView.topSpaceView.isHidden = self.bounds.size.height < 200
        self.profileView.timerLabel.isHidden = self.bounds.size.height < 200

    }
    
    // MARK: - Setup
    private func setupViews() {
        
        
        self.addSubview(profileView)
             profileView.translatesAutoresizingMaskIntoConstraints = false
             NSLayoutConstraint.activate([
                 profileView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor,constant: 0),
                 profileView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                 profileView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
             ])
    }
    
    // MARK: - Public Methods
    func configure(withName name: String, profileImageUrl: String?, status : ISMCallStatus?, isMinimised : Bool = false) {
        
        profileView.nameLabel.text = name
        
        if status == .started{
            timer?.invalidate()
            if let time = ISMCallManager.shared.callConnectedTime{
                self.startTime = time
                startTimer()
            }else{
                profileView.timerLabel.text = ISMCallConstants.connectingText
            }
          
        }else if let status
        {
            profileView.timerLabel.text =  isMinimised ? "MINIMISED" : status.rawValue
        }
        
        profileView.profileImageView.setImage(urlString:profileImageUrl)
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            // self?.updateTimer()
            self?.updateAppTimer()
        }
    }
    
    //    private func updateTimer() {
    //        seconds += 1
    //        let minutes = seconds / 60
    //        let remainingSeconds = seconds % 60
    //        timerLabel.text = String(format: "%02d:%02d", minutes, remainingSeconds)
    //    }
    func updateAppTimer() {
        guard let startTime = startTime else {
            // Call has not started yet, do nothing
            return
        }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        // Update your app's timer display with the elapsed time
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime) % 60
        profileView.timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        // print("Timer: \(timerString)")
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
