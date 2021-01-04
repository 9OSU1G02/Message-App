//
//  ProfileTableViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/29/20.
//

import UIKit

class UserProfileTableViewController: UITableViewController {
    // MARK:  Properties
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userOnlineImageView: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        return header
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let user = user else { return}
        if indexPath.section == 1 && indexPath.row == 0{
            // Go to chat room
            if let currentUser = User.currentUser{
                let user2 = user
                let chatRoomId = startChat(user1: currentUser, user2: user2)
                let privateChatView = ChatViewController(chatRoomId: chatRoomId, recepientId: user.id, recipientName: user.username)
                privateChatView.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(privateChatView, animated: true)
            }
        }
        else if indexPath.section == 1 && indexPath.row == 1 {
            guard let url = URL(string: "TEL://\(user.phoneNumber)") else {
                print("Cant create url phone number")
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK:  SetupUI
    private func setupUI() {
        tableView.tableFooterView = UIView()
        if let user = user {
            title = user.username
            usernameLabel.text = user.username
            statusLabel.text = user.status
            phoneNumberLabel.text = user.phoneNumber
            if user.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user.avatarLink) { [weak self](avatarImage) in
                    self?.avatarImage.image = avatarImage?.circleMasked
                }
            }
            if user.isOnline {
                userOnlineImageView.image = UIImage(named: "green")!.circleMasked
                userOnlineImageView.isHidden = false
            }
            else {
                userOnlineImageView.isHidden = true
            }
        }
    }
    deinit {
        print("Deinit UserProfile")
    }
}


