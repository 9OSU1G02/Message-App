//
//  StartChat.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/29/20.
//

import Foundation
import Firebase
// MARK:  StartChat

//Eeach chat room have 2 recent items corresponding to 2 user
func startChat(user1: User, user2: User) -> String {
    let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    return chatRoomId
}

//make sure we have 2 recents because (e.g: user1 start chat but user 2 has delete recent so user 2 will not get message at recent from user 1 ---> Create new recent for user 2)
func RestartChat(chatRoomId: String, memberIds: [String]) {
    FirebaseUserListener.shared.downloadUsersFromFireBase(withIds: memberIds) { (users) in
        if users.count > 0 {
            createRecentItems(chatRoomId: chatRoomId, users: users)
        }
    }
}

func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    /*
     let user1Id = "123"
     let user2Id = "456"
     let value = user1Id.compare(user2Id).rawValue ---> value = 1
     */
    var chatRoomId = ""
    let value = user1Id.compare(user2Id).rawValue
    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
    return chatRoomId
}

//Create recent for both user ( each user is sender of it own recent)
func createRecentItems(chatRoomId: String, users: [User]) {
    //Hold ID of 2 user (ID current user and ID of user that current user want to chat with) in chat room (asssume that none of 2 user have recent object)
    var memberIdsCreateRecent = [users.first!.id, users.last!.id]
    //Does user have recent? by checking if the chat room has any recent (just in case 1 user delete recent or both user delete recent), if don't have we create recent
    FirebaseReference(.Recent).whereField(CHAT_ROOM_ID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        //snapshot hold recent object
        guard let snapshot = snapshot else {
            return
        }
        
        //If have Any Recent in Firestore
        if snapshot.isEmpty == false {
            //Check which user already have recent object -> Remove that user from memberIdsCreateRecent
            memberIdsCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsCreateRecent)
            }
        //If memberIdsCreateRecent is empty (both of 2 user don't need create recent) code below (for loop) will not run
        for userId in memberIdsCreateRecent {
            //If userId == User.currentId -> the sender is ourself otherwise the other user will be the sender
            let senderUser = userId == User.currentId ? User.currentUser! : getReceiverFrom(users: users)
            let receiverUser = userId == User.currentId ? getReceiverFrom(users: users) : User.currentUser!
            
            let recentObject = RecentChat(id: UUID().uuidString, chatRoomId: chatRoomId, senderID: senderUser.id, senderName: senderUser.username, receiverId: receiverUser.id, receiverName: receiverUser.username, date: Date(), memberIds: [senderUser.id, receiverUser.id], unreadCounter: 0, avatarLink: receiverUser.avatarLink, lassMessage: "")
            FirebaseRecentListener.shared.saveRecent(recentObject)
        }
    }
}

func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
    var memberIdsToCreateRecent = memberIds
    for recentData in snapshot.documents {
        //recentData.data() : RecentChat key:value format
        let currentRecent = recentData.data() as Dictionary
        //currentRecent[key] have match up with senderId properties of struct RecentChat
        if let currentUserId = currentRecent[SENDER_ID] {
            //if currentUserId exits in memberIdsToCreateRecent we remove currentUserId because currentRecent blong to currentUserId(because currentRecent[SENDER_ID] match up with currentUserId) so we don't want to create another recent
            if memberIdsToCreateRecent.contains(currentUserId as! String ) {
                memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)! )
            }
        }
    }
    return memberIdsToCreateRecent
}

//Return [User] that don't containt current user
func getReceiverFrom(users: [User]) -> User {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}
