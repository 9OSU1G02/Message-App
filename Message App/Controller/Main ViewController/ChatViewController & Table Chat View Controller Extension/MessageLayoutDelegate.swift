//
//  MessageLayoutDelegate.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import MessageKit
extension ChatViewController: MessagesLayoutDelegate {
    
    // Show pull to  load more or show date of 3 message was sent pull to load more : 40,  date of 3 message : 18, not 3 message : 0
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            // set different size for pull to load more
            if indexPath.section == 0 && (allLocalMessage.count > displayingMessagesCount) {
                return 40
            }
            return 18
        }
        return 0
    }
    
    // Config hight Show message status in cell bottom If its latest message and from current user
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    // Config hight Show time message was sent If is NOT last sections ( last message )
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        //If is the last section ( last messsage ) in chat room
        return indexPath.section != mkMessages.count - 1 ? 10 : 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //Avatar in chat room will be First character in User name
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitals.capitalized))
    }
}


extension ChannelChatViewController: MessagesLayoutDelegate {
    
    // Show pull to  load more or show date of 3 message was sent pull to load more : 40,  date of 3 message : 18, not 3 message : 0
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            // set different size for pull to load more
            if indexPath.section == 0 && (allLocalMessage.count > displayingMessagesCount) {
                return 40
            }
            return 18
        }
        return 0
    }
    
    // Config hight Show message status in cell bottom If its latest message and from current user
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }
        
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //Avatar in chat room will be First character in User name
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitals.capitalized))
    }
}
