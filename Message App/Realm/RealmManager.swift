//
//  RealmManager.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/29/20.
//

import Foundation
import RealmSwift
// terminal --> open /Users/$USER/Library/Developer/CoreSimulator/Devices ---> Search .realm ---> choose Devices tab ---> choose default.realm
class RealmManager {
    static let shared = RealmManager()
    let realm = try! Realm()
    private init () {}
    func saveToRealm<T: Object> (_ object: T) {
        do {
            try realm.write {
                // update: .all: If new object id is same as id of old object ( same primary key which we set its id), it go to overwrite old object with new value
                realm.add(object, update: .all)
            }
        }
        catch {
            print("Error saving realm Object",error.localizedDescription)
        }
    }
}
