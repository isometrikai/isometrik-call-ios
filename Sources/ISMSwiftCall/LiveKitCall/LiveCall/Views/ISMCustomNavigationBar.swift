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
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
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
        backgroundColor =  .clear
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: backButton.leadingAnchor,constant: 10 ).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: groupMembersButton.leadingAnchor ,constant: 10 ).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
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
