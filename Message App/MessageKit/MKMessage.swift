//
//  MKMessage.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import MessageKit
import CoreLocation
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
    var photoItem: PhotoMessage?
    var videoItem: VideoMessage?
    var locationItem: LocationMessage?
    var audioItem: AudioMessage?
    init(localMessage: LocalMessage) {
        self.mkSender = MKSender(senderId: localMessage.senderId, displayName: localMessage.senderName)
        self.messageId = localMessage.id
        self.sentDate = localMessage.date
        switch localMessage.type {
        case TEXT:
            self.kind = MessageKind.text(localMessage.message)
        case PHOTO:
            self.photoItem = PhotoMessage()
            self.kind = MessageKind.photo(self.photoItem ?? PhotoMessage())
        case VIDEO:
            self.videoItem = VideoMessage(url: nil)
            self.kind = MessageKind.video(self.videoItem ?? VideoMessage(url: nil))
        case LOCATION:
            self.locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longtitude))
            self.kind = MessageKind.location(self.locationItem ?? LocationMessage(location: CLLocation(latitude: 0, longitude: 0)))
        case AUDIO:
            self.audioItem = AudioMessage(duration: Float(localMessage.audioDuration))
            self.kind = MessageKind.audio(self.audioItem ?? AudioMessage(duration: 0))
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
