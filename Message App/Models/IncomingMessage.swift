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
        var mkMessage = MKMessage(localMessage: localMessage)
        
        if localMessage.type == PHOTO {
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { (image) in
                mkMessage.photoItem?.image = image
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == VIDEO {
            //Download thumbnail
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { (thumbnail) in
                //Download Video
                FileStorage.downloadVideo(videoLink: localMessage.videoUrl) { (readyToPlay, videoFileName) in
                    //url of video locall
                    let videoUrl = URL(fileURLWithPath: fileInDocumentsDicrectory(fileName: videoFileName))
                    mkMessage.videoItem = VideoMessage(url: videoUrl)
                    mkMessage.kind = MessageKind.video(mkMessage.videoItem ?? VideoMessage(url: nil))
                }
                mkMessage.videoItem?.image = thumbnail
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        if localMessage.type == LOCATION {
            
        }
        
        if localMessage.type == AUDIO {
            FileStorage.downloadAudio(audioLink: localMessage.audioUrl) { (audioFileName) in
                let audioURL = URL(fileURLWithPath: fileInDocumentsDicrectory(fileName: audioFileName))
                mkMessage.audioItem?.url = audioURL
            }
            self.messageCollectionView.messagesCollectionView.reloadData()
        }
        //case localMessage.type == Text
        return mkMessage
    }
}
