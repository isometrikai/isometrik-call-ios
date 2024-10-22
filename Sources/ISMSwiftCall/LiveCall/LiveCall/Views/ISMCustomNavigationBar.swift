//
//  ISMCustomNavigationBar.swift
//  LiveKitCall
//
//  Created by Ajay Thakur on 11/04/24.
//

import Foundation
import UIKit


protocol ISMCustomNavigationBarDelegate {
    func didTapLeftBarButton()
    func didTapRightBarButton()
}

class ISMCustomNavigationBar: UIView,AppearanceProvider {
    
    
    var delegate : ISMCustomNavigationBarDelegate?
    
    var view = UIView()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    
    let backButton = UIButton()
    let groupMembersButton = UIButton()
    
    var hideRightBarButton : Bool = true {
        didSet{
            groupMembersButton.isHidden = hideRightBarButton
        }
    }
    
    func setupView() {
        addbackButton()
        addGroupMembersButton()
        hideRightBarButton = true
        // Customize the appearance of your custom navigation bar
        // Set background to clear
        view.backgroundColor = .clear

        // Add titleLabel and subtitleLabel to the view
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        addSubview(view)

        // Disable autoresizing mask
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false

        // Add constraints for titleLabel and subtitleLabel
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            // Title label should be above subtitle label
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: 0),
            
            // Subtitle label constraints
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Center the subtitle below the title
            subtitleLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor)
        ])

        // Add constraints for the view containing the labels
        NSLayoutConstraint.activate([
            // Position the view between backButton and groupMembersButton
            view.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10),
            view.trailingAnchor.constraint(equalTo: groupMembersButton.leadingAnchor, constant: -10),
            
            // Center the view vertically in the navigation bar
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        
    }
    
    func addbackButton(){
        addSubview(backButton)
        backButton.setImage(appearance.images.minimize, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        backButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backButton.autoresizesSubviews = true
        backButton.addTarget(self, action: #selector(backButtonTapped(sender: )), for: .touchUpInside)
    }
    
    func addGroupMembersButton(){
        addSubview(groupMembersButton)
        groupMembersButton.setImage(appearance.images.group, for: .normal)
        groupMembersButton.translatesAutoresizingMaskIntoConstraints = false
        groupMembersButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        groupMembersButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        groupMembersButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        groupMembersButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        groupMembersButton.autoresizesSubviews = true
        groupMembersButton.addTarget(self, action: #selector(groupMembersTapped(sender: )), for: .touchUpInside)

    }
    
    @objc func backButtonTapped(sender : UIButton) {
        self.delegate?.didTapLeftBarButton()
    }
    
    
    @objc func groupMembersTapped(sender : UIButton) {
        self.delegate?.didTapRightBarButton()
    }
}
