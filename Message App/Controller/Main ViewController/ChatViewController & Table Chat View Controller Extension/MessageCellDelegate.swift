//
//  MessageCellDelegate.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import MessageKit
import SKPhotoBrowser
import AVFoundation
import AVKit

// MARK: - ChatViewController
extension ChatViewController: MessageCellDelegate {
            func didTapImage(in cell: MessageCollectionViewCell) {
        //Index path of cell user was tap
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            //This is photo Message
            if mkMessage.photoItem != nil && mkMessage.photoItem!.image != nil {
                
                //create SKPhoto Array from UIImage
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                images.append(photo)
                
                //Create PhotoBrowser Instance, and present.
                let browser = SKPhotoBrowser(photos: images)
                //If how have array of skphoto , you can choose what image show first
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: nil)
            }
            
            //This is video Message
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil {
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                let sesstion = AVAudioSession.sharedInstance()
                try! sesstion.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                moviePlayer.player = player
                present(moviePlayer, animated: true) {
                    //Play video
                    moviePlayer.player!.play()
                }
            }
        }
    }
    
    //Show MapView when user tap at location message
    func didTapMessage(in cell: MessageCollectionViewCell) {
        //Index path of cell user was tap
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            if mkMessage.locationItem != nil {
                let mapView = MapViewController()
                mapView.location = mkMessage.locationItem?.location
                navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }
    
    //Hande scenarios when user pressed play button on audio cell
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}

// MARK: - ChannelChatViewController

extension ChannelChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        //Index path of cell user was tap
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            //This is photo Message
            if mkMessage.photoItem != nil && mkMessage.photoItem!.image != nil {
                
                //create SKPhoto Array from UIImage
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                images.append(photo)
                
                //Create PhotoBrowser Instance, and present.
                let browser = SKPhotoBrowser(photos: images)
                //If how have array of skphoto , you can choose what image show first
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: nil)
            }
            //This is video Message
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil {
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                let sesstion = AVAudioSession.sharedInstance()
                try! sesstion.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                moviePlayer.player = player
                present(moviePlayer, animated: true) {
                    //Play video
                    moviePlayer.player!.play()
                }
            }
        }
    }
    
    //Show MapView when user tap at location message
    func didTapMessage(in cell: MessageCollectionViewCell) {
        //Index path of cell user was tap
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            if mkMessage.locationItem != nil {
                let mapView = MapViewController()
                mapView.location = mkMessage.locationItem?.location
                navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }
    
    //Hande scenarios when user pressed play button on audio cell
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}
