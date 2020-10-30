//
//  FirebaseTypingListener.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/30/20.
//

import Foundation
import Firebase
class FirebaseTypingListener {
    static let shared = FirebaseTypingListener()
    var typingListener: ListenerRegistration!
    private init() {
        
    }
    //Get data of isTyping(key userId ,value is bool) from firebase if have
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        //Listening for anychange in chatRoomId
        typingListener = FirebaseReference(.Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
                guard let snapshot = snapshot else {
                return
            }
            //Check if have any chatRoomId in Typing area, if don't we create it
            if snapshot.exists {
                for data in snapshot.data()! {
                    //If data (isTyping) dont' blong to the current user --> belong to second user , we want get it
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
            }
            else {
                //If there is no typing area at all, it means our other user is not typing anyway
                completion(false)
                //Create isTyping for current user
                FirebaseReference(.Typing).document(chatRoomId).setData([User.currentId : false])
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        FirebaseReference(.Typing).document(chatRoomId).updateData([User.currentId : typing])
    }
    
    func removeTypingListener() {
        self.typingListener.remove()
    }
}
