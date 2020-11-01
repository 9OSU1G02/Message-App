//
//  Channel.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import Foundation
import FirebaseFirestoreSwift
import UIKit
struct Channel: Codable {
    var id = ""
    var name = ""
    var adminId = ""
    var memberIds = [""]
    var avatarLink = ""
    var aboutChannel = ""
    @ServerTimestamp var createdDate = Date()
    @ServerTimestamp var lastMessageDate = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case lastMessageDate = "date"
        case adminId
        case memberIds
        case avatarLink
        case aboutChannel
    }
}
