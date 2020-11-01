//
//  FirebaseChannelListener.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import Foundation
import FirebaseFirestore

class FirebaseChannelListener {
    static let shared = FirebaseChannelListener()
    var channelListener:  ListenerRegistration!
    private init() {
        
    }
    // MARK: - Fetching
    func downloadUserChannelFromFirebase(completion: @escaping (_ allUsersChannels: [Channel]) -> Void ) {
        //Get all channels where adminId is current user id, addSnapshotListener to keep geting update about anychange in firebase
        channelListener = FirebaseReference(.Channel).whereField(ADMIN_ID, isEqualTo: User.currentId).addSnapshotListener({ (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("No documents for user channels")
                return
            }
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        }
        )
    }
    // MARK: - Add, Update, Delete
    func saveChannel(_ channel: Channel) {
        do {
            try FirebaseReference(.Channel).document(channel.id).setData(from: channel)
        } catch {
            print("Error saving channel", error.localizedDescription)
        }
    }
    
    func deleteChannel(_ channel: Channel) {
        FirebaseReference(.Channel).document(channel.id).delete()
    }
    
    func downloadSubscribedChannelFromFirebase(completion: @escaping (_ allChannelsSubscribed: [Channel]) -> Void ) {
        //Get all channels where memberId contain current user id, addSnapshotListener to keep geting update about anychange
        channelListener = FirebaseReference(.Channel).whereField(MEMBER_IDS, arrayContains: User.currentId)
            .addSnapshotListener({ (snapshot, error) in
                //If any change in firebase code below will run
                guard let documents = snapshot?.documents else {
                    print("No documents for subscribed channels")
                    return
                }
                var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                    return try? queryDocumentSnapshot.data(as: Channel.self)
                }
                
                
                allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
                completion(allChannels)
            })
    }
    
    func downloadAllChannelFromFirebase(completion: @escaping (_ allChannels: [Channel]) -> Void ) {
        //Get all channels where memberId contain current user id
        FirebaseReference(.Channel).getDocuments{(snapshot,error) in
            guard let documents = snapshot?.documents else {
                print("No documents for all channels")
                return
            }
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            //Remove any channel that user have subscribed
            allChannels = self.removeSubscribedChannels(allChannels)
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        }
    }
    
    //Remove any channel that user have subscribed
    func removeSubscribedChannels(_ allChannels: [Channel]) -> [Channel]  {
        var newChannels: [Channel] = []
        for channel in allChannels {
            if channel.memberIds.contains(User.currentId) == false {
                newChannels.append(channel)
            }
        }
        return newChannels
    }
    
    func removeChannelListener() {
        self.channelListener.remove()
    }
}
