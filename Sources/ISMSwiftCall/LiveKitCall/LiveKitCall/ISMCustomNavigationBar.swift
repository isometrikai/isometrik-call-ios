//
//  ISMCustomNavigationBar.swift
//  LiveKitCall
//
//  Created by Ajay Thakur on 11/04/24.
//

import Foundation
import UIKit

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
    
    func setupView() {
        // Customize the appearance of your custom navigation bar
        backgroundColor =  .clear
        let backButton = UIButton()
        addSubview(backButton)
        backButton.setImage(appearance.images.back, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        backButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backButton.autoresizesSubviews = true
        backButton.addTarget(self, action: #selector(backButtonTapped(sender: )), for: .touchUpInside)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: backButton.leadingAnchor,constant: 10 ).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10 ).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    @objc func backButtonTapped(sender : UIButton) {
        self.delegate?.didTapBackButton()
    }
}
