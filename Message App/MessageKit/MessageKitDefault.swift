//
//  MKSender.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import MessageKit



struct MKSender: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

enum MessageDefaults {
    //Bubble Message
    static let bubbleColorOutGoing = UIColor(named: "OutgoingMessage") ?? .systemBlue
    static let bubbleColorIncoming = UIColor(named: "IncomingMessage") ?? UIColor.darkGray
}
