//
//  RecentChat.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/29/20.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentChat: Codable {
    var id = ""
    var chatRoomId = ""
    var senderID = ""
    var senderName = ""
    var receiverId = ""
    var receiverName = ""
    // @ServerTimestamp come form FirebaseFirestoreSwift : if user doesn't provie a value for specific variable, Firebase will take a sever date and assgin value for variable
    @ServerTimestamp  var date = Date()
    var memberIds = [""]
    var unreadCounter = 0
    var avatarLink = ""
    var lassMessage = ""
    var isReceiverOnline = false
}
