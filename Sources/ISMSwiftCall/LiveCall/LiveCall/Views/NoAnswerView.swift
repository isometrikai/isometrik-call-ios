//
//  File.swift
//  
//
//  Created by Ajay Thakur on 18/07/24.
//

import Foundation
import UIKit

class NoAnswerView: UIView {
    
    private let blurEffectView: UIVisualEffectView
    private let callStatusLabel: UILabel
    private let noAnswerLabel: UILabel
    private let cancelButton: UIButton
    
    override init(frame: CGRect) {
        // Initialize the blur effect
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        // Initialize the call status label
        callStatusLabel = UILabel()
        callStatusLabel.textAlignment = .center
        callStatusLabel.textColor = .white
        callStatusLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        noAnswerLabel = UILabel()
        noAnswerLabel.text = "No answer"
        noAnswerLabel.textAlignment = .center
        noAnswerLabel.textColor = .white
        noAnswerLabel.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        
        
        cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Add the blur effect view
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
        // Add the call status label
        callStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        noAnswerLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        blurEffectView.contentView.addSubview(callStatusLabel)
        blurEffectView.contentView.addSubview(noAnswerLabel)
        blurEffectView.contentView.addSubview(cancelButton)
        
        
        NSLayoutConstraint.activate([
            callStatusLabel.centerXAnchor.constraint(equalTo: blurEffectView.contentView.centerXAnchor),
            callStatusLabel.topAnchor.constraint(equalTo: blurEffectView.contentView.topAnchor, constant: 280),
            noAnswerLabel.topAnchor.constraint(equalTo: callStatusLabel.bottomAnchor,constant:10),
            noAnswerLabel.centerXAnchor.constraint(equalTo: callStatusLabel.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 40),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.centerXAnchor.constraint(equalTo: blurEffectView.contentView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: blurEffectView.contentView.bottomAnchor, constant: -80)
        ])
    }
    
    func setCallStatus(text: String) {
        callStatusLabel.text = text
    }
}
