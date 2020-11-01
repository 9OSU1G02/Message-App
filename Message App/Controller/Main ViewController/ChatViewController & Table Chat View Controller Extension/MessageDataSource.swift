//
//  MessageDataSource.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import MessageKit
extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return mkMessages.count
    }
    
    // MARK:  Cell Top Label
    
    //Show pull to  load more or show date of for third message was sent
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        //Show timestamp for third message
        if indexPath.section % 3 == 0 {
            //If we at section 0 and we have more massager to show -> show pull to load more
            let showLoadMore = (indexPath.section == 0) && (allLocalMessage.count > displayingMessagesCount)
            //Show Pull to load more OR timestamp
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.lightGray
            return NSAttributedString(string: text, attributes: [.font : font, .foregroundColor : color])
        }
        return nil
    }
    
    // MARK: - Cell bottom label
    
    // Show message status in cell bottom If its latest message and from current user
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ? message.status + " " + message.readDate.time() : ""
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.blue
            return NSAttributedString(string: status, attributes: [.font : font, .foregroundColor : color])
        }
        return nil
    }
    
    // MARK: - Message bottom label
    //Show time message was sent If is NOT last sections ( last message )
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
            if indexPath.section !=  mkMessages.count - 1 {
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.red
            return NSAttributedString(string: message.sentDate.time(), attributes: [.font : font, .foregroundColor : color])
        }
        return nil
    }
}


extension ChannelChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return currentUser
    }
    //each message is a separate section ---> each section is message we want to display
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return mkMessages[indexPath.section]
    }
    // total message we want to display
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        mkMessages.count
    }
    
    // MARK:  cell Top Label
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        //Show timestamp for third message
        if indexPath.section % 3 == 0 {
            //If we at section 0 and we have more massager to show -> show pull to load more
            let showLoadMore = (indexPath.section == 0) && (allLocalMessage.count > displayingMessagesCount)
            //Show Pull to load more OR timestamp
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.lightGray
            return NSAttributedString(string: text, attributes: [.font : font, .foregroundColor : color])
        }
        return nil
    }
        
    // MARK: - Message bottom label
    //Show time message was sent If is NOT last sections ( last message )
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
            if indexPath.section !=  mkMessages.count - 1 {
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.red
            return NSAttributedString(string: message.sentDate.time(), attributes: [.font : font, .foregroundColor : color])
        }
        return nil
    }
}
