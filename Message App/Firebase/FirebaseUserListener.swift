//
//  FirebaseUserListener.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/27/20.
//

import Foundation
import Firebase
import ProgressHUD
import GoogleSignIn
import FirebaseFirestoreSwift
class FirebaseUserListener {
    static let shared = FirebaseUserListener()
    
    // MARK: - Registration
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let result = result else {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            result.user.sendEmailVerification { (error) in
                //have error when send email verification
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                }
                else {
                    ProgressHUD.showSuccess("Verification Email was send")
                    //error = nil
                    completion(error)
                }
            }
            //Create user and save it to firestore
            let user = User(id: result.user.uid, username: email, email: email, status: "Available", avatarLink: "", hasSeenOnboard: false)
            self?.saveUserToFirestore(user)
        }
    }
    
    func reSendEmailVerification(email: String, completion: @escaping SendEmailVerificationCallback) {
        
        Auth.auth().currentUser?.sendEmailVerification(completion: completion)
        
    }
    
    func resetPasswordFor(email: String, completion: @escaping SendPasswordResetCallback) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    func updateUserHasSeenOnboardingWithFireBase(user: User) {
        var user = user
        FirebaseReference(.User).document(User.currentId).updateData(["hasSeenOnboard" : true])
        user.hasSeenOnboard = true
        saveUserLocally(user)
    }
    
    // MARK: - Login with email
    func loginUserWith(email: String, password: String, completion: @escaping (_ error:Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            guard let result = result, result.user.isEmailVerified else {
                return
            }
            //Email is verified
            FirebaseUserListener.shared.downLoadUserFromFirestore(userId: result.user.uid)
            completion(error,true)
            
        }
    }
    
    // MARK: - Logout
    
    func logOut(completion: @escaping (_ error: Error?) -> Void) {
        do {
            FirebaseRecentListener.shared.updateIsReceiverOnline(false)
            try Auth.auth().signOut()
            USER_DEFAULT.removeObject(forKey: CURRENT_USER)
            completion(nil)
        }
        catch{
            completion(error)
        }
    }
    
    // MARK: - Goole Sign In
    func signInWithGoogle(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?, completion: @escaping (_ error: Error?) -> Void) {
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (result, error) in
            guard let result = result else {
                completion(error)
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            let uid = result.user.uid
            
            guard let username = result.user.displayName, let email = result.user.email else {
                return
            }
            
            //If id of google account don't exits in User --> return false --> save user to firestore
            self.isGoogleAccountAlreadyExits(uid: uid) { (user) in
                if let user = user {
                    saveUserLocally(user)
                }
                else {
                    let user = User(id: uid, username: username, email: email, status: "Available", avatarLink: "", hasSeenOnboard: false)
                    saveUserLocally(user)
                    self.saveUserToFirestore(user)
                }
                //error = nil
                completion(error)
            }
            
        }
    }
    
    private func isGoogleAccountAlreadyExits(uid: String, completion: @escaping (User?) -> Void) {
        
        FirebaseReference(.User).document(uid).getDocument { (querySnapshot, error) in
            
            guard let document = querySnapshot else {
                completion(nil)
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject, user.id == uid {
                    completion(user)
                }
                else {
                    completion(nil)
                }
            case .failure(let error):
                print("Error decoding user ", error)
            }
        }
    }
    
    // MARK: - Download User
    
    func downLoadUserFromFirestore(userId: String) {
        FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
            guard let document = snapshot else {
                print("No document for user")
                return
            }
            let result = Result {
                //Decode User JSON form firestore to User
                try? document.data(as: User.self)
            }
            switch result {
            case .success(let user):
                if let user = user {
                    saveUserLocally(user)
                }
                else {
                    ProgressHUD.showFailed("User does not exits")
                }
            case .failure(let error):
                print("Error decoding user", error)
            }
        }
    }
    
    //Return Users with specified id
    func downloadUsersFromFireBase(withIds: [String], completion: @escaping (_ allUsers: [User] )-> Void) {
        var count = 0
        var userArray: [User] = []
        
        for userId in withIds {
            FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
                guard let document = snapshot else {
                    print("No document for user")
                    return
                }
                //Create User from document
                let user = try? document.data(as: User.self)
                userArray.append(user!)
                count += 1
                //When get all user ( count 5 == witdIds.count =5 )
                if count == withIds.count {
                    completion(userArray)
                }
            }
        }
    }
    
    func downloadAllUserFromFireBase(completion: @escaping (_ allUsers: [User] )-> Void) {
        
        FirebaseReference(.User).getDocuments{ (snapshot, error) in
            var users : [User] = []
            guard let document = snapshot?.documents else {
                print("No document in all Users")
                return
            }
            //Decode [QueryDocumentSnapshot] -> [User]
            let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            for user in allUsers {
                //Don't want append current user
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            completion(users)
        }
    }
    
    func avatarImageFromUser(userId: String, isRefresh:Bool ,completion: @escaping (_ avatarImage: UIImage, _ avatarLink: String ) -> Void ) {
        FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
            guard let document = snapshot else {
                print("No document for user")
                return
            }
            let result = Result {
                //Decode User JSON form firestore to User
                try? document.data(as: User.self)
            }
            switch result {
            case .success(let user):
                if let user = user {
                    if isRefresh == false {
                        FileStorage.downloadImage(imageUrl: user.avatarLink) { (avatarImage) in
                            if let avatarImage = avatarImage {
                                completion(avatarImage, user.avatarLink)
                            }
                        }
                    }
                    else {
                        FileStorage.downloadImageWithOutCheckForLocal(imageUrl: user.avatarLink) { (avatarImage) in
                            if let avatarImage = avatarImage {
                                completion(avatarImage, user.avatarLink)
                            }
                        }
                    }
                }
                else {
                    ProgressHUD.showFailed("Avatar Link don't exits")
                }
            case .failure(let error):
                print("Error decoding user", error)
            }
        }
    }
    
    
    
    // MARK: - Save user to firestore & UsersDefault
    
    func saveUserToFirestore(_ user: User) {
        do {
            try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print("\(error.localizedDescription) adding user")
        }
    }
    
    //Encode user to JSON then save to UserDefault
    
}
