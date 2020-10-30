//
//  OutgoingMessage.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery

class OutgoingMessage {
    class func send(chatRoomId: String, text:String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        //Default format for LocalMessage
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatRoomId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = SENT
        
        if text != nil {
            sendTextMessage(message: message, text: text!, memberIds: memberIds)
        }
        // Update recent
        FirebaseRecentListener.shared.updateRecents(chatRoomId: chatRoomId, lastMessage: message.message)
    }
    
    class func sendMessage(message: LocalMessage, memberIds: [String]) {
        //Save message to Realm
        RealmManager.shared.saveToRealm(message)
        //MemberIDs: hold 2 id because we gona save message on Firebase for both sender and reciver
        for memberId in memberIds {
            FirebaseMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }
}

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {
    message.message = text
    message.type = TEXT
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
}


