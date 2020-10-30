//
//  FirebaseRecentListener.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/29/20.
//

import Foundation
class FirebaseRecentListener {
    static let shared = FirebaseRecentListener()
    private init () {}
    
    func saveRecent(_ recent: RecentChat) {
        do{
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }
        catch {
            print("Error save recent chat, \(error.localizedDescription)")
        }
    }
    
    //When user chat , unread messager sill increase but when user exit chat room we will reset unread message to 0
    func resetRecentCounter(chatRoomId: String) {
        //Get document by sender if have ( maximum is only 1 sender -> only 1 document -> only 1 recent )
        FirebaseReference(.Recent).whereField(CHAT_ROOM_ID, isEqualTo: chatRoomId).whereField(SENDER_ID, isEqualTo: User.currentId).getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                print("no documents for recent")
                return
            }
            
            let allRecents = documents.compactMap { (querySnapshot) -> RecentChat? in
                return try? querySnapshot.data(as: RecentChat.self)
            }
            if allRecents.count > 0 {
                self.clearUnreadCounter(recent: allRecents.first!)
            }
        }
    }
    
    func clearUnreadCounter(recent: RecentChat) {
        var newRecent = recent
        newRecent.unreadCounter = 0
        saveRecent(newRecent)
    }
    
    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) -> Void ) {
        //Get all Recent have senderId == current user id, add listener -> code will run when some thing change in Recent on firebase
        FirebaseReference(.Recent).whereField(SENDER_ID, isEqualTo: User.currentId).addSnapshotListener { (snapshot, error) in
            var recentChasts: [RecentChat] = []
            guard let document = snapshot?.documents else {
                print("No Document for recent for recent chats")
                return
            }
            //Convert element of document from JSON to RecentChat
            let allRecents = document.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            for recent in allRecents {
                //Only get recent have last message inside ( case user click start chat but then don't chat anny thing so we don't want get that recent to show )
                if recent.lassMessage != "" {
                    recentChasts.append(recent)
                }
            }
            //Short recent chat by date
            recentChasts.sort(by: {$0.date! > $1.date!} )
            completion(recentChasts)
        }
    }
    
    func deleteRecent(_ recent: RecentChat) {
        FirebaseReference(.Recent).document(recent.id).delete()
    }
    
    // MARK: - Update Recents
    func updateRecents(chatRoomId: String, lastMessage: String) {
        //update last message for both recent of 2 user
        FirebaseReference(.Recent).whereField(CHAT_ROOM_ID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("no document for recent update")
                return
            }
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            for recent in allRecents {
                self.updateRecentItemWithNewMessage(recent: recent, lastMessage: lastMessage)
            }
        }
    }
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String) {
        var tempRecent = recent
        //If we not sender -> that Recent belong to another user -> updateRecent
        if tempRecent.senderID != User.currentId {
            tempRecent.unreadCounter += 1
        }
        tempRecent.lassMessage = lastMessage
        tempRecent.date = Date()
        self.saveRecent(tempRecent)
    }
}
