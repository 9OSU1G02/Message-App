//
//  IncomingMessage.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import MessageKit
class IncomingMessage {
    var messageCollectionView: MessagesViewController
    init(messageCollectionView: MessagesViewController) {
        self.messageCollectionView = messageCollectionView
    }
    func createMKMessage(localMessage: LocalMessage) -> MKMessage? {
        let mkMessage = MKMessage(localMessage: localMessage)
        return mkMessage
    }
}
