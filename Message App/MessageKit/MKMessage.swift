//
//  MKMessage.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import MessageKit
import CoreLocation
class MKMessage: NSObject, MessageType {
    
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mkSender: MKSender
    var sender: SenderType { return mkSender }
    var senderInitials: String
    
    var photoItem: PhotoMessage?
    var videoItem: VideoMessage?
    var locationItem: LocationMessage?
    var audioItem: AudioMessage?

    var status: String
    var readDate: Date
    
    init(message: LocalMessage) {
        
        self.messageId = message.id
        
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        switch message.type {
        case TEXT:
            self.kind = MessageKind.text(message.message)
            
        case PHOTO:
            
            let photoItem = PhotoMessage(path: message.pictureUrl)
            
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
            
        case VIDEO:
            
            let videoItem = VideoMessage(url: nil)
            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem
            
        case LOCATION:
            
            let locationItem = LocationMessage(location: CLLocation(latitude: message.latitude, longitude: message.longtitude))
            
            self.kind = MessageKind.location(locationItem)
            self.locationItem = locationItem
            
        case AUDIO:
            
            let audioItem = AudioMessage(duration: 2.0)
            
            self.kind = MessageKind.audio(audioItem)
            self.audioItem = audioItem
            
        default:
            self.kind = MessageKind.text(message.message)
            print("unknown message type")
        }
        
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
    }
}
