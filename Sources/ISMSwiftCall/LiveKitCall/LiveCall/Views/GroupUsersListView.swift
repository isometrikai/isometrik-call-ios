//
//  File.swift
//
//
//  Created by Ajay Thakur on 18/07/24.
//

import Foundation
import UIKit

// Define an enum to represent the sections
enum MemberSection {
    case connected([ISMCallMember])
    case notConnected([ISMCallMember])
    
    var members: [ISMCallMember] {
        switch self {
        case .connected(let users), .notConnected(let users):
            return users
        }
    }
    
    var title: String {
        switch self {
        case .connected(let users):
            return "\(users.count) connected"
        case .notConnected:
            return "Not connected"
        }
    }
}


class GroupUsersListView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private let usersTableView = UITableView()
    private let dismissButton = UIButton()
    
    private var connectedUsers: [ISMCallMember] = []
    private var notConnectedUsers: [ISMCallMember] = []
    
    var memberSections: [MemberSection] {
        var sections = [MemberSection]()
        if !connectedUsers.isEmpty {
            sections.append(.connected(connectedUsers))
        }
        if !notConnectedUsers.isEmpty {
            sections.append(.notConnected(notConnectedUsers))
        }
        return sections
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .black
        self.usersTableView.backgroundColor = .black
        dismissButton.setImage(Appearance().images.minimize, for: .normal)
        dismissButton.setTitleColor(.blue, for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.register(GroupUserTableViewCell.self, forCellReuseIdentifier: "GroupUserTableViewCell")
        usersTableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(usersTableView)
        
        NSLayoutConstraint.activate([
            usersTableView.topAnchor.constraint(equalTo: dismissButton.bottomAnchor,constant: 8),
            usersTableView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 20),
            usersTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            usersTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
    private func setupAppearance() {
        // Add rounded corners to the top
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = false
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 5
    }
    
    
    func setUsers(_ members: [ISMCallMember]) {
        self.loadData(members)
        if let id = (self.superview as? ISMLiveCallView)?.meetingId{
            ISMCallManager.shared.fetchMembers(meetingId: id){ members in
                DispatchQueue.main.async {
                    (self.superview as? ISMLiveCallView)?.members = members
                }
                self.loadData(members)
                
            }
        }
        
    }
    
    private func loadData(_ members: [ISMCallMember]){
        let users = members.filter{!($0.memberId != ISMConfiguration.getUserId())}
        
        self.connectedUsers = users.filter({ $0.isPublishing ?? false
        })
        self.notConnectedUsers = users.filter({ !($0.isPublishing ?? false)
        })
        DispatchQueue.main.async {
            self.usersTableView.reloadData()
            self.usersTableView.reloadData()
        }
    }
    
    @objc private func dismissButtonTapped() {
        (superview as? ISMLiveCallView)?.dismissUsersListView()
    }
    
    
    // TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return memberSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberSections[section].members.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UsersSectionHeaderView()
        headerView.configure(with: memberSections[section].title)
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // Adjust the height as needed
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupUserTableViewCell", for: indexPath) as! GroupUserTableViewCell
        // Reset corner rounding
        cell.roundCorners(corners: [], radius: 0)
        
        // Apply corner rounding based on position
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        if numberOfRows == 1 {
            cell.roundCorners(corners: [.allCorners], radius: 10)
        } else if indexPath.row == 0 {
            cell.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        } else if indexPath.row == numberOfRows - 1 {
            cell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
        }
        let user = memberSections[indexPath.section].members[indexPath.row]
        cell.configure(with: user)
        return cell
    }
}

class GroupUserTableViewCell: UITableViewCell {
    private let containerView = UIView()
    private let userImageView = UIImageView()
    private let userNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .lightGray
        containerView.backgroundColor = .darkGray
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 20
        userImageView.clipsToBounds = true
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.backgroundColor = .white
        containerView.addSubview(userImageView)
        
        userNameLabel.textColor = .white
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(userNameLabel)
        
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            userImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            userImageView.widthAnchor.constraint(equalToConstant: 40),
            userImageView.heightAnchor.constraint(equalToConstant: 40),
            userImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).withPriority(.defaultLow),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor)
        ])
        
        self.contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: 0),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0.5),
        ])
    }
    
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.contentView.layer.mask = mask
        }
    }
    
    
    func configure(with member: ISMCallMember) {
        userImageView.setImage(urlString: member.userProfileImageURL ?? member.memberProfileImageURL )
        userNameLabel.text =  member.userName ?? member.memberName
    }
}


class UsersSectionHeaderView: UIView {
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        // Constraints for the label
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
    }
    
    func configure(with title: String) {
        label.text = title
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
