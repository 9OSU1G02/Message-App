//
//  FirebaseMessageListener.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import Firebase
class FirebaseMessageListener {
    static let shared = FirebaseMessageListener()
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!
    //Check message in local Database (realm) if don't available go to firebase also check for message if have message so download it and save to realm
    func checkForOldChat(_ documentId: String, collectionId: String) {
        FirebaseReference(.Message).document(documentId).collection(collectionId).getDocuments { (snapshot, error) in
            guard let document = snapshot?.documents else {
                print("No Document for old chats")
                return
            }
            var oldMessages = document.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            oldMessages.sort(by: { $0.date < $1.date })
            for message in oldMessages {
                RealmManager.shared.saveToRealm(message)
            }
        }
    }
    
    //get message form firebase which have date came after the last date of message in local database then save it local database
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        //newChatListener : listener for change in firebase
        newChatListener = FirebaseReference(.Message).document(documentId).collection(collectionId).whereField(DATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
            // If have change in firebase code bellow will run
            guard let snapshot = snapshot else {return}
            for change in snapshot.documentChanges {
                //If change in firebase is add ( mean message added)
                if change.type == .added {
                    let result = Result {
                        //Convert to Local Message
                        try? change.document.data(as: LocalMessage.self)
                    }
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            //Make sure this messge that we recieve not we sent be cause before sent we have save this message already save it in realm
                            if message.senderId != User.currentId {
                                RealmManager.shared.saveToRealm(message)
                            }
                        }
                        else {
                            print("Document doesnt exist")
                        }
                    case .failure(let error):
                        print("Error decoding local message",error)
                    }
                }
            }
        })
    }
    
    // MARK:  Add, Update, Delete
    func addMessage(_ message: LocalMessage, memberId: String) {
        do {
            let _ = try FirebaseReference(.Message).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        }
        catch {
            print("error saving messagae",error.localizedDescription)
        }
    }
    
    // MARK: - Remove Listener
    func removeListener() {
        newChatListener.remove()
    }
}
