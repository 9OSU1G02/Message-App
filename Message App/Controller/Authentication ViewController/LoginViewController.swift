//
//  ViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/27/20.
//

import UIKit
import Foundation
import ProgressHUD
import Firebase
import GoogleSignIn

protocol AuthenticationFormCheck {
    func checkFormIsValid() -> Bool
    func updateForm(formIsValid: Bool)
}
class LoginViewController: UIViewController {
    // MARK: - Properties
    
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var emailTextFiled: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginWithGoogleButtonLabel: UIButton!
    @IBOutlet weak var loginButtonLabel: UIButton!
    @IBOutlet weak var resentEmailButtonLabel: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
        setupBackgroundTap()
        configureGoogleSignIN()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        emailTextFiled.removeTarget(self, action: nil, for: .editingChanged)
        passwordTextField.removeTarget(self, action: nil, for: .editingChanged)
    }
    // MARK: - IBActions
    
    @IBAction func textEntrySecurityButtonPressed(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        passwordTextField.isSecureTextEntry == true ? sender.setImage(UIImage(named: "Suche"), for: .normal) : sender.setImage(UIImage(named: "visible_off"), for: .normal)
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        showForgotPasswordViewController()
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailTextFiled.text, let password = passwordTextField.text {
            FirebaseUserListener.shared.loginUserWith(email: email, password: password) { [weak self] in
                guard let self = self else { return}
                    // TODO: - Go to main view
                        self.goToMainView()
                        FirebaseRecentListener.shared.updateIsReceiverOnline(true)
            }
        }
    }
    
    @IBAction func loginWithGoogleButtonPressed(_ sender: UIButton) {
        handleGoogleLogin()
    }
    
    @IBAction func dontHaveAccountButtonPressed(_ sender: Any) {
        showSignUpViewController()
    }
    
    @IBAction func resentEmailButtonPress(_ sender: UIButton) {
        if let email = emailTextFiled.text {
            FirebaseUserListener.shared.reSendEmailVerification(email: email) { (error) in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                }
                else {
                    ProgressHUD.showSuccess("Email Verified Link was send")
                }
            }
        }
    }
    
    
    // MARK: - Google Login
    
    func configureGoogleSignIN() {
        //The object to be notified when authentication is finished.
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func handleGoogleLogin() {
        //The view controller used to present `SFSafariViewContoller`
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        //perform sign in when click on Login with google
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    
    // MARK: - Navigation
    
    private func showSignUpViewController() {
        let signUpVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: SIGN_UP_STORYBOARD_ID) as! SignUpViewController
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    private func showForgotPasswordViewController() {
        let forgotPasswordVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: FORGOT_PASSWORD_STORYBOARD_ID) as! ForgotPasswordViewController
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    // MARK: - Selections
    @objc func textDidChange(_ sender: UITextField) {
        let formIsValid = checkFormIsValid()
        updateForm(formIsValid: formIsValid)
    }
    
    // MARK: - Configration
    
    func configureNotificationObservers() {
        emailTextFiled.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        }
    
    func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        emailTextFiled.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "ic_mail")))
        passwordTextField.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "Key")))
        
        let googleIcon = UIImageView(image: #imageLiteral(resourceName: "Google"))
        googleIcon.setDimensions(height: 22, width: 22)
        loginWithGoogleButtonLabel.addSubview(googleIcon)
        googleIcon.centerY(inView: loginWithGoogleButtonLabel)
        googleIcon.anchor(left: loginWithGoogleButtonLabel.leftAnchor, paddingLeft: 15)
    }
    
    
    // MARK: - Navigation
    private func goToMainView() {
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: MAIN_VIEW_STORYBOARD_ID) as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        present(mainView, animated: true, completion: nil)
    }
    
    deinit {
        print("Deinit loginViewController")
    }
}

// MARK: - Extension

extension LoginViewController: AuthenticationFormCheck {
    func updateForm(formIsValid: Bool) {
        if formIsValid {
            loginButtonLabel.alpha = 1
            loginButtonLabel.isEnabled = true
            
        }
        else {
            loginButtonLabel.alpha = 0.3
            loginButtonLabel.isEnabled = false
            resentEmailButtonLabel.isHidden = true
        }
    }
    
    func checkFormIsValid() -> Bool {
        return emailTextFiled.text != "" && passwordTextField.text != ""
    }
}

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //Happen when user choose cancel
        if user == nil {
            return
        }
        FirebaseUserListener.shared.signInWithGoogle(signIn, didSignInFor: user, withError: error) { [weak self](error) in
            guard let self = self else { return }
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            // TODO: - Go to main view
            self.goToMainView()
            FirebaseRecentListener.shared.updateIsReceiverOnline(true)
        }
    }
    
}
