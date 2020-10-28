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
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
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
            self.saveUserToFirestore(user)
        }
    }
    
    func reSendEmailVerification(email: String, completion: @escaping SendEmailVerificationCallback) {

            Auth.auth().currentUser?.sendEmailVerification(completion: completion)

    }
    
    func resetPasswordFor(email: String, completion: @escaping SendPasswordResetCallback) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    // MARK: - Login with email
    func loginUserWith(email: String, password: String, completion: @escaping (_ error:Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            guard let result = result, result.user.isEmailVerified else {
                completion(error,false)
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
     
      if let error = error {
        completion(error)
        return
      }

      guard let authentication = user.authentication else { return }
      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                        accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (result, error) in
            guard let result = result else {
                completion(error)
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            if let username = result.user.displayName, let email = result.user.email {
                let user = User(id: result.user.uid, username: username, email: email, status: "Available", avatarLink: "", hasSeenOnboard: false)
                self.saveUserToFirestore(user)
                saveUserLocally(user)
            }
            else {
                ProgressHUD.showError("Can't get information from your google account")
            }
            //error = nil
            completion(error)
        }
    }
    
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