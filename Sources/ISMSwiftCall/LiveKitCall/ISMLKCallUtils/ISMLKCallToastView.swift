//
//  ISMLKCallToastView.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 23/09/23.
//

import Foundation
import UIKit

class ISMLKCallToastView: UIView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.backgroundColor = UIColor(white: 0, alpha: 0.7)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    init(message: String) {
        super.init(frame: .zero)
        messageLabel.text = message
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
        self.backgroundColor = .black
        addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageLabel.frame = bounds
    }
}
