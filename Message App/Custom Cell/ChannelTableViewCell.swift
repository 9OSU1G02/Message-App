//
//  ChannelTableViewCell.swift)
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {
    // MARK: - IbOutlets
    var isRefresh = false
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var memeberCountLabel: UILabel!
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(channel: Channel) {
        nameLabel.text = channel.name
        aboutLabel.text = channel.aboutChannel
        memeberCountLabel.text = "\(channel.memberIds.count) members"
        //Time elapsed since last message was send
        lastMessageDateLabel.text = timeElapsed(channel.lastMessageDate ?? Date())
        lastMessageDateLabel.adjustsFontSizeToFitWidth = true
        FirebaseChannelListener.shared.avatarImageFromChannel(channelId: channel.id, isRefresh: isRefresh) { (avatarImage, avatarLink) in
            self.avatarImageView.image = avatarImage.circleMasked
            FirebaseReference(.Channel).document(channel.adminId).updateData(["avatarLink" : avatarLink])
        }
        isRefresh = false
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
}
