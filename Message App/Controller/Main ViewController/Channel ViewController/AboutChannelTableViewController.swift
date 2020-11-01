//
//  AboutChannelTableViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import UIKit

protocol AboutChannelTableViewControllerDelegate: NSObject {
    func didClickFollow()
}
class AboutChannelTableViewController: UITableViewController {
    // MARK: - Properties
    var channel: Channel!
    weak var delegate: AboutChannelTableViewControllerDelegate?
    // MARK: - IBOutlet
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutTextViewLabel: UITextView!
    @IBOutlet weak var memebersLabel: UILabel!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        showChannelData()
        setAvatar(avatarLink: channel.avatarLink)
        configureRightBarButton()
    }
    // MARK: - Configure
    private func showChannelData() {
        title = channel.name
        nameLabel.text = channel.name
        memebersLabel.text = "\(channel.memberIds.count) Members"
        aboutTextViewLabel.text = channel.aboutChannel
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
        else {
            avatarImageView.image = UIImage(named: "avatar")
        }
    }
    
    private func configureRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followChannel))
    }
            
    // MARK: - Selectors
    @objc func followChannel() {
        //Add current user to channel, then update channel on firebase
        channel.memberIds.append(User.currentId)
        FirebaseChannelListener.shared.saveChannel(channel)
        //Update allChanels when user has follow ( remove channel user just follow out of All Channels segment)
        delegate?.didClickFollow()
        navigationController?.popViewController(animated: true)
    }
}
