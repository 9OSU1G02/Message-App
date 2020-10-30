//
//  MKMessage.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import MessageKit

struct MKMessage: MessageType {
    var mkSender : MKSender
    var sender: SenderType {
        return mkSender
    }
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    var incoming: Bool
    var senderInitals: String
    var status: String
    var readDate: Date
    
    init(localMessage: LocalMessage) {
        self.mkSender = MKSender(senderId: localMessage.senderId, displayName: localMessage.senderName)
        self.messageId = localMessage.id
        self.sentDate = localMessage.date
        switch localMessage.type {
        case TEXT:
            self.kind = MessageKind.text(localMessage.message)
        default:
            self.kind = MessageKind.text(localMessage.message)
            print("unknow message")
        }
        self.incoming = User.currentId != mkSender.senderId
        self.senderInitals = localMessage.senderInitials
        self.status = localMessage.status
        self.readDate = localMessage.readDate
    }
}
