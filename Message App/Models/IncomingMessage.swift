//
//  IncomingMessage.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import MessageKit
import CoreLocation
class IncomingMessage {
    var messageCollectionView: MessagesViewController
    
    init(_collectionView: MessagesViewController) {
        messageCollectionView = _collectionView
    }
    
    
    //MARK: - CreateMessage
    
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        
        let mkMessage = MKMessage(message: localMessage)
        
        if localMessage.type == PHOTO {
            
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { (image) in
                
                mkMessage.photoItem?.image = image
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == VIDEO {
            
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { (thumbNail) in
                
                FileStorage.downloadVideo(videoLink: localMessage.videoUrl) { (readyToPlay, fileName) in
                    
                    let videoURL = URL(fileURLWithPath: fileInDocumentsDicrectory(fileName: fileName))
                    
                    let videoItem = VideoMessage(url: videoURL)
                    
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }
                
                mkMessage.videoItem?.image = thumbNail
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == LOCATION {
            
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longtitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
        }
        
        if localMessage.type == AUDIO {
            
            let audioMessage = AudioMessage(duration: Float(localMessage.audioDuration))
            
            mkMessage.audioItem = audioMessage
            mkMessage.kind = MessageKind.audio(audioMessage)
            
            FileStorage.downloadAudio(audioLink: localMessage.audioUrl) { (fileName) in
                
                let audioURL = URL(fileURLWithPath: fileInDocumentsDicrectory(fileName: fileName))
                
                mkMessage.audioItem?.url = audioURL
            }
            self.messageCollectionView.messagesCollectionView.reloadData()
        }
        
        return mkMessage
    }

    
}
