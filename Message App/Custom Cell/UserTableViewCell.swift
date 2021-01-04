//
//  UserTableViewCell.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/29/20.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    var isRefresh = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userOnlineImageView: UIImageView!
    
    func configure(user: User){
        usernameLabel.text = user.username
        statusLabel.text = user.status
        
        FirebaseUserListener.shared.avatarImageFromUser(userId: user.id, isRefresh: isRefresh) { (avatarImage, avatarLink) in
                self.avatarImage.image = avatarImage.circleMasked
                FirebaseReference(.User).document(user.id).updateData(["avatarLink" : avatarLink])
        }
        isRefresh = false
        if user.isOnline {
            userOnlineImageView.image = UIImage(named: "green")!.circleMasked
            userOnlineImageView.isHidden = false
        }
        else {
            userOnlineImageView.isHidden = true
        }
    }
    
    func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                self.avatarImage.image = avatarImage?.circleMasked
            }
        }
        else {
            self.avatarImage.image = UIImage(named: "Messenger")
        }
    }
}
