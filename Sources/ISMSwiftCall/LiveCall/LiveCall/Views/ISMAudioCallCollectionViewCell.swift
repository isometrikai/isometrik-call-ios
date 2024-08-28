//
//  File.swift
//  
//
//  Created by Ajay Thakur on 10/07/24.
//

import Foundation
import UIKit

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
        profileView.frame = bounds
        profileView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(profileView)
    }
    
    // MARK: - Public Methods
    func configure(member: ISMCallMember?,status: ISMCallStatus?) {
        
        profileView.nameLabel.text = member?.memberName
        if status == .reconnecting{
            profileView.timerLabel.text = "Reconnecting..."
        }
        else if status == .started{
            timer?.invalidate()
            if let time = ISMCallManager.shared.callConnectedTime{
                self.startTime = time
                startTimer()
            }else{
                profileView.timerLabel.text = ISMCallConstants.connectingText
            }
          
        }else if let status
        {
            profileView.timerLabel.text =  status.rawValue
        }
        
        
        profileView.profileImageView.setImage(urlString:member?.memberProfileImageURL,placeholderImage: CircularImagePlaceholder.createCircularInitialsPlaceholder(name: member?.memberName ?? "Unknown", size: CGSize(width:profileView.profileImageView.bounds.width , height: profileView.profileImageView.bounds.height)))
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
        nameLabel.textColor = .white
        timerLabel.textColor = .white
        
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
}
