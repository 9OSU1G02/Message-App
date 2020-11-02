//
//  RecentTableViewCell.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/29/20.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

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
        usernameLabel.text = recent.receiverName
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
        setAvatar(avatarLink: recent.avatarLink)
        dateLabel.text = timeElapsed(recent.date ?? Date() )
        lastMessageLabel.adjustsFontSizeToFitWidth = true
    }
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                self.avatarImage.image = avatarImage?.circleMasked
            }
        }
        else {
            self.avatarImage.image = UIImage(named: AVATAR_DEFAULT_IMAGE)
        }
    }
}
