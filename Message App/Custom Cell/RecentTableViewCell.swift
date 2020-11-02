//
//  RecentTableViewCell.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/29/20.
//

import UIKit
import Firebase
class RecentTableViewCell: UITableViewCell {
    var isRefresh = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCounterLabel: UILabel!
    @IBOutlet weak var unreadCounterBackgroundView: UIView!
    @IBOutlet weak var isReceiverOnline: UIImageView!
    
    func configureCell(recent: RecentChat) {
        
        //Adjut font size for fit width with maximum shrink 90% origin text
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.9
        
        lastMessageLabel.text = recent.lassMessage
        lastMessageLabel.adjustsFontSizeToFitWidth = true
        lastMessageLabel.numberOfLines = 2
        lastMessageLabel.minimumScaleFactor = 0.9
        if recent.unreadCounter != 0 {
            unreadCounterLabel.text = "\(recent.unreadCounter)"
            unreadCounterBackgroundView.isHidden = false
        }
        else {
            unreadCounterBackgroundView.isHidden = true
        }
        if recent.isReceiverOnline {
            isReceiverOnline.image = UIImage(named: "green")!.circleMasked
            isReceiverOnline.isHidden = false
        }
        else {
            isReceiverOnline.isHidden = true
        }
        FirebaseUserListener.shared.avatarImageFromUser(userId: recent.receiverId, isRefresh: isRefresh) { (avatarImage, avatarLink) in
                self.avatarImage.image = avatarImage.circleMasked
                FirebaseReference(.Recent).document(recent.id).updateData(["avatarLink" : avatarLink])
            }
        
        if isRefresh {
            FirebaseUserListener.shared.downloadUsersFromFireBase(withIds: [recent.receiverId]) { (user) in
                self.usernameLabel.text = user.first?.username
                FirebaseReference(.Recent).document(recent.id).updateData(["receiverName" : user.first?.username ?? ""])
            }
        }
        else {
            usernameLabel.text = recent.receiverName
        }
        
        
        
        dateLabel.text = timeElapsed(recent.date ?? Date() )
        lastMessageLabel.adjustsFontSizeToFitWidth = true
        isRefresh = false
    }
    
    private func setAvatar(receiverId: String, isRefresh: Bool) {
            FirebaseUserListener.shared.avatarImageFromUser(userId: receiverId, isRefresh: isRefresh) { (avatarImage, avatarLink) in
                self.avatarImage.image = avatarImage.circleMasked
            }
    }
    private func setRecentName(receiverId: String, isRefresh: Bool) {
        FirebaseUserListener.shared.downloadUsersFromFireBase(withIds: [receiverId]) { (user) in
            self.usernameLabel.text = user.first?.username
        }
    }
    
}
