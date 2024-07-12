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
        
        
        self.addSubview(profileView)
             profileView.translatesAutoresizingMaskIntoConstraints = false
             NSLayoutConstraint.activate([
                 profileView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor,constant: 0),
                 profileView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                 profileView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
             ])
    }
    
    // MARK: - Public Methods
    func configure(withName name: String, profileImageUrl: String?, status : ISMCallStatus?) {
        
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
            profileView.timerLabel.text =  status.rawValue
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
