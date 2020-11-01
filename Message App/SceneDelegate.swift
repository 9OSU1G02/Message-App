//
//  SceneDelegate.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/27/20.
//

import UIKit
import Firebase
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    //Listening if there are any changes in our loggin user
    var authListener: AuthStateDidChangeListenerHandle?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        self.autoLogin()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        LocationManager.shared.startUpdating()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        LocationManager.shared.stopUpdating()
    }
    
    // MARK: - AutoLogin
    func autoLogin() {
        //Listenting for authenticcation (log in,log out ...)
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let authListener = self.authListener {
                //When user logged in we to remove these listner because there is no need to keep listening for changes agains
                Auth.auth().removeStateDidChangeListener(authListener)
                //If has logged in user and also have user in UserDefault it means that we do have a logged in user -> Present MainView
                if user != nil && USER_DEFAULT.object(forKey: CURRENT_USER) != nil {
                    DispatchQueue.main.async {
                        self.goToMainView()
                    }
                }
            }
        })
    }
    
    private func goToMainView() {
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: MAIN_VIEW_STORYBOARD_ID) as! UITabBarController
        window?.rootViewController = mainView
    }

}

