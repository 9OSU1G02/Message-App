//
//  FirebaseCollectionReference.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/27/20.
//

import Foundation
import FirebaseFirestore

enum FirebaseCollectionReference: String {
    case User
    case Recent
    case Message
    case Typing
}

func FirebaseReference(_ collectionReference: FirebaseCollectionReference) -> CollectionReference {
    //Get specified path within the firestore
    return Firestore.firestore().collection(collectionReference.rawValue)
}
