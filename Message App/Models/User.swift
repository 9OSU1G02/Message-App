//
//  User.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/27/20.
//

import Foundation
import Firebase
struct User: Codable, Equatable {
    var id = ""
    var username: String
    var email: String
    var status: String
    var avatarLink = ""
    var hasSeenOnboard = false
    
    static var currentId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    //Get current User form UserDefault
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = USER_DEFAULT.data(forKey: CURRENT_USER) {
                do {
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(User.self, from: dictionary)
                    return user
                } catch  {
                    fatalError("Error decoding user form UserDefaults: \(error.localizedDescription)")
                }
            }
        }
        return nil
    }
}
    
func saveUserLocally(_ user: User) {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        USER_DEFAULT.set(data,forKey: CURRENT_USER)
    } catch {
        print("Can't save user to userDefaults")
    }
}
