//
//  LocalMessage.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/29/20.
//

import Foundation

import Foundation
import RealmSwift
//Need to conform Object to use Realm (Object is type we going to save Data in Realm is mean save everything as long as that data that confrom Object)
class LocalMessage: Object, Codable {
    @objc dynamic var id = ""
    @objc dynamic var chatRoomId = ""
    @objc dynamic var date = Date()
    @objc dynamic var senderName = ""
    @objc dynamic var senderId = ""
    @objc dynamic var senderInitials = ""
    @objc dynamic var readDate = Date()
    @objc dynamic var type = ""
    @objc dynamic var status = ""
    @objc dynamic var message = ""
    @objc dynamic var audioUrl = ""
    @objc dynamic var videoUrl = ""
    @objc dynamic var pictureUrl = ""
    @objc dynamic var latitude = 0.0
    @objc dynamic var longtitude = 0.0
    @objc dynamic var audioDuration = 0.0
    //PrimaryKey : what goint to indentify object
    override class func primaryKey() -> String? {
        return "id"
    }
}
