//
//  User.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/27/20.
//

import Foundation

struct User: Codable, Equatable {
    var id = ""
    var username: String
    var email: String
    var status: String
    var avataLink = ""
    var hasSeenOnboard = false
}
