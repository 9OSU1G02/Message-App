//
//  InputBarAcessoryViewDelegate.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import MessageKit
import InputBarAccessoryView

// MARK: - ChatViewController
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    //Called when text in InputBar change
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text != "" {
            typingIndicatorUpdate()
        }
        //If text in InputBar empty -> show micro
        updateMicButtonStatus(show: text == "")
    }
    
    //Called when user press send
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //Input bar have different components, we going thourgh every component and find the one is holding a text
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                messageSend(text: text, photo: nil, video: nil, audio: nil, location: nil)
            }
        }
        //Clear input textField after send message
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}

// MARK: - ChannelChatViewController
extension ChannelChatViewController: InputBarAccessoryViewDelegate {
    //Called when text in InputBar change
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        //If text in InputBar empty -> show micro
        updateMicButtonStatus(show: text == "")
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //Input bar have different components, we going thourgh every component and find the one is holding a text
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                messageSend(text: text, photo: nil, video: nil, audio: nil, location: nil)
            }
        }
        
        //Clear inputbar after send message
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
