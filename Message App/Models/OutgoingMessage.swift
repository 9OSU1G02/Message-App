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
        
        if let text = text {
            sendTextMessage(message: message, text: text, memberIds: memberIds)
        }
        
        if let  photo = photo {
            sendPhotoMessage(message: message, photo: photo, memberIds: memberIds)
        }
        
        if let  video = video {
            sendVideoMessage(message: message, video: video, memberIDs: memberIds)
        }
        if let location = location {
            sendLocationMessage(message: message, memberIDs: memberIds)
        }
        if let audio = audio {
            sendAudioMessage(message: message, memberIDs: memberIds, audioFileName: audio, audioDuration: audioDuration)
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
    
    class func sendChannelMessage(message: LocalMessage, channel: Channel) {
        
        RealmManager.shared.saveToRealm(message)
        FirebaseMessageListener.shared.addChannelMessage(message, channel: channel)
    }
    
    class func sendChannel(channel: Channel, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?) {
        
        let currentUser = User.currentUser!
        var channel = channel
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = channel.id
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = SENT
        
        if text != nil {
            sendTextMessage(message: message, text: text!, memberIds: channel.memberIds, channel: channel)
        }
        
        if photo != nil {
            sendPhotoMessage(message: message, photo: photo!, memberIds: channel.memberIds, channel: channel)
        }
        
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIDs: channel.memberIds, channel: channel)
        }
        
        if location != nil {
            sendLocationMessage(message: message, memberIDs: channel.memberIds, channel: channel)
        }
        
        if audio != nil {
            sendAudioMessage(message: message, memberIDs: channel.memberIds, audioFileName: audio!, audioDuration: audioDuration, channel: channel)
        }
        channel.lastMessageDate = Date()
        FirebaseChannelListener.shared.saveChannel(channel)
    }
    
}
// MARK: - Send Text Message
func sendTextMessage(message: LocalMessage, text: String, memberIds: [String], channel: Channel? = nil) {
    message.message = text
    message.type = TEXT
    if let channel = channel {
        OutgoingMessage.sendChannelMessage(message: message, channel: channel)
    }
    else {
        OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    }
}
// MARK: - Send Photo Message
func sendPhotoMessage(message: LocalMessage, photo: UIImage, memberIds: [String], channel: Channel? = nil) {
    message.message = "Picture Message"
    message.type = PHOTO
    //Convert date to String then assign that for name of file
    let fileName = Date().stringDate()
    //Save image locally
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)
    //Save image in MediaMessages/Photo/message.chatRoomId/ folder , file name = "_\(fileName)" + ".jpg" (Firestore)
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    FileStorage.uploadImage(photo, directory: fileDirectory) { (imageUrl) in
        if imageUrl != nil {
            message.pictureUrl = imageUrl!
            if let channel = channel {
                OutgoingMessage.sendChannelMessage(message: message, channel: channel)
            }
            else {
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
            }
        }
    }
}
// MARK: - Send Video Message
func sendVideoMessage(message: LocalMessage, video: Video, memberIDs: [String], channel: Channel? = nil) {
    message.message = "Video Message"
    message.type = VIDEO
    
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".mp4"

    let editor = VideoEditor()
    
    editor.process(video: video) { (precessedVideo, videoUrl) in
        
        if let tempPath = videoUrl {
            
            let thubnail = videoThumbnail(video: tempPath)
            
            FileStorage.saveFileLocally(fileData: thubnail.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
            
            FileStorage.uploadImage(thubnail, directory: thumbnailDirectory) { (imageLink) in
                
                if imageLink != nil {
                    
                    let videoData = NSData(contentsOfFile: tempPath.path)
                    
                    FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mp4")
                    
                    FileStorage.uploadVideo(videoData!, directory: videoDirectory) { (videoLink) in
                        
                        message.pictureUrl = imageLink ?? ""
                        message.videoUrl = videoLink ?? ""
                        
                        if channel != nil {
                            OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
                        } else {
                            OutgoingMessage.sendMessage(message: message, memberIds: memberIDs)
                        }
                    }
                }
            }
        }
    }
}
// MARK: - Send Location Message
func sendLocationMessage(message: LocalMessage, memberIDs: [String], channel: Channel? = nil) {
    let currentLocation = LocationManager.shared.currentLocation
    message.message = "Location Message"
    message.type = LOCATION
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longtitude = currentLocation?.longitude ?? 0.0
    OutgoingMessage.sendMessage(message: message, memberIds: memberIDs)
    if let channel = channel {
        OutgoingMessage.sendChannelMessage(message: message, channel: channel)
    }
    else {
        OutgoingMessage.sendMessage(message: message, memberIds: memberIDs)
    }
}

// MARK: - Send Audio Message
func sendAudioMessage(message: LocalMessage, memberIDs: [String], audioFileName: String, audioDuration: Float, channel: Channel? = nil) {
    message.message = "Audio message"
    message.type = AUDIO
    let fileDirectory = "MediaMessages/Audio/" + "\(message.chatRoomId)/" + "_\(audioFileName)" + ".m4a"
    FileStorage.uploadAudio(audioFileName, directory: fileDirectory) { (audioUrl) in
        if audioUrl != nil {
            message.audioUrl = audioUrl ?? ""
            message.audioDuration = Double(audioDuration)
            if let channel = channel {
                OutgoingMessage.sendChannelMessage(message: message, channel: channel)
            }
            else {
                OutgoingMessage.sendMessage(message: message, memberIds: memberIDs)
            }
        }
    }
}
