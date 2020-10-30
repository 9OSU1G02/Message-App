//
//  MessageCellDelegate.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import MessageKit
extension ChatViewController: MessageCellDelegate {
    
    //Custom text color for message
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        //return system color depending on a dark or light mode
        return .label
    }
    
    //Custom background for bubble message
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? MessageDefaults.bubbleColorOutGoing : MessageDefaults.bubbleColorIncoming
    }
    
    //Custom tail for message bubble
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}

