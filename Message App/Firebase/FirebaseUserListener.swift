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
enum UserDefaultError: String, Error {
    case unableToGetSignInMethod = "Unable to get Sign In method from User Default"
    case unableToGetIdToken = "Unable to get Id Token from User Default"
    case unableToGetAccessToken = "Unable to get Access Token from User Default"
}
enum SignInMethod: String {
    case email
    case google
    
    static func saveSignInMethod(_ method: SignInMethod) {
        UserDefaults.standard.set(method.rawValue, forKey: SIGN_IN_METHOD)
    }
    
    static func getSignInMethod(completed: (Result<SignInMethod,UserDefaultError>) -> Void){
        guard let rawValue = UserDefaults.standard.string(forKey: SIGN_IN_METHOD), let method = SignInMethod(rawValue: rawValue) else {
            completed(.failure(.unableToGetSignInMethod))
            return
        }
        completed(.success(method))
    }
    
    static func saveIdAndAccessToken(id: String, access: String) {
        UserDefaults.standard.set(id, forKey: ID_TOKEN)
        UserDefaults.standard.set(access, forKey: ACCESSTOKEN)
    }
    
    static func getIdTokenAndAccessToken(completed: @escaping (Result<[String],UserDefaultError>) -> Void) {
        guard let idToken = UserDefaults.standard.string(forKey: ID_TOKEN),
              let accessToken = UserDefaults.standard.string(forKey: ID_TOKEN)
        else {
            completed(.failure(.unableToGetIdToken))
            return
        }
        completed(.success([idToken,accessToken]))
    }

}
class FirebaseUserListener {
    static let shared = FirebaseUserListener()
    
    // MARK: - Registration
    func registerUserWith(email: String, password: String,phoneNunber: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
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
            let user = User(id: result.user.uid, username: email, email: email, status: "Available", phoneNumber: phoneNunber, avatarLink: "")
            self.saveUserToFirestore(user)
        }
    }
    
    // SendEmailVerificationCallback ~= (Error?) -> Void
    func reSendEmailVerification(email: String, completion: @escaping SendEmailVerificationCallback) {
        Auth.auth().currentUser?.sendEmailVerification(completion: completion)
    }
    
    // SendPasswordResetCallback ~= (Error?) -> Void
    func resetPasswordFor(email: String, completion:  @escaping SendPasswordResetCallback) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    // MARK: - Login with email
    func loginUserWith(email: String, password: String, completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            guard let result = result, result.user.isEmailVerified else {
                ProgressHUD.showError(error?.localizedDescription ?? "Email is not Verified", interaction: false)
                return
            }
            //Email is verified
            SignInMethod.saveSignInMethod(.email)
            FirebaseUserListener.shared.downLoadUserFromFirestore(userId: result.user.uid)
            completion()
        }
    }
    
    // MARK: - Logout
    
    func logOut(completion: @escaping (_ error: Error?) -> Void) {
        do {
            FirebaseRecentListener.shared.updateIsReceiverOnline(false)
            FirebaseUserListener.shared.updateIsUserOnline(false)
            try Auth.auth().signOut()
            USER_DEFAULT.removeObject(forKey: CURRENT_USER)
            completion(nil)
        }
        catch{
            completion(error)
        }
    }
    
    // MARK: - Change Password
    func changePassword(signInMethod: SignInMethod,oldPassword: String = "", newPassword: String, completion: @escaping (Bool) -> Void) {
        let user = Auth.auth().currentUser
        var credential: AuthCredential
        
        switch signInMethod {
        case .email:
            credential = EmailAuthProvider.credential(withEmail: User.currentUser!.email, password: oldPassword)
        case .google:
            var idToken = ""
            var accessToken = ""
            //If user sign in with google we need get id token and access token to peform change password
            SignInMethod.getIdTokenAndAccessToken { (result) in
                switch result {
                case .success(let token):
                    idToken = token[0]
                    accessToken = token[1]
                case .failure(_):
                    break
                }
            }
            credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        }
                 
        user?.reauthenticate(with: credential) { result,error  in
            if let error = error {
                // An error happened.
                ProgressHUD.showError(error.localizedDescription)
                return
            } else {
                Auth.auth().currentUser?.updatePassword(to: newPassword) { (error) in
                    if let error = error {
                        ProgressHUD.showError(error.localizedDescription)
                    }
                    else {
                        completion(true)
                    }
                }
            }
        }
    }
    
    // MARK: - Goole Sign In
    func signInWithGoogle(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?, completion: @escaping (_ error: Error?) -> Void) {
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) {[weak self] (result, error) in
            guard let self = self else { return }
            guard let result = result else {
                completion(error)
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            let uid = result.user.uid
            
            guard let username = result.user.displayName, let email = result.user.email else {
                return
            }
            
            SignInMethod.saveSignInMethod(.google)
            SignInMethod.saveIdAndAccessToken(id: authentication.idToken, access: authentication.accessToken)
            
            self.isGoogleAccountAlreadyExits(uid: uid) { (user) in
                if let user = user {
                    saveUserLocally(user)
                }
                //If id of google account don't exits in User --> return false --> save user to firestore
                else {
                    let user = User(id: uid, username: username, email: email, status: "Available", phoneNumber: result.user.phoneNumber ?? "", avatarLink: "")
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
        FirebaseReference(.User).addSnapshotListener { (snapshot, error) in
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
        //        FirebaseReference(.User).getDocuments{ (snapshot, error) in
        //            var users : [User] = []
        //            guard let document = snapshot?.documents else {
        //                print("No document in all Users")
        //                return
        //            }
        //            //Decode [QueryDocumentSnapshot] -> [User]
        //            let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
        //                return try? queryDocumentSnapshot.data(as: User.self)
        //            }
        //            for user in allUsers {
        //                //Don't want append current user
        //                if User.currentId != user.id {
        //                    users.append(user)
        //                }
        //            }
        //            completion(users)
        //        }
    }
    
    // MARK: - Download Image
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
    
    func updateIsUserOnline(_ isUserOnline: Bool) {
        guard User.currentId != "" else { return}
        FirebaseReference(.User).document(User.currentId).getDocument {[weak self] (snapshot, error) in
            guard let self = self else { return }
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
                if var user = user {
                    user.isOnline = isUserOnline
                    self.saveUserToFirestore(user)
                    saveUserLocally(user)
                }
                else {
                    print("User does not exits")
                }
            case .failure(let error):
                print("Error decoding user", error)
            }
        }
    }
}
