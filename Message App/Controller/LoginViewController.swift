//
//  ViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/27/20.
//

import UIKit
import Foundation
class LoginViewController: UIViewController {
    // MARK: - Properties
    
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var emailTextFiled: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginWithGoogleButtonLabel: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
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
        
    }
    
    @IBAction func loginWithGoogleButtonPressed(_ sender: UIButton) {

    }
    
    @IBAction func dontHaveAccountButtonPressed(_ sender: Any) {
        showSignUpViewController()
    }
    
    
    // MARK: - Navigation
    
    private func showSignUpViewController() {
        let signUpVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: SIGN_UP_STORYBOARD_ID)
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    private func showForgotPasswordViewController() {
        let forgotPasswordVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: FORGOT_PASSWORD_STORYBOARD_ID)
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    // MARK: - Configration
    
    func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        emailTextFiled.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "ic_mail")))
        passwordTextField.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "Key")))
        passwordTextField.clearsOnBeginEditing = false
        
        let googleIcon = UIImageView(image: #imageLiteral(resourceName: "Google"))
        googleIcon.setDimensions(height: 22, width: 22)
        loginWithGoogleButtonLabel.addSubview(googleIcon)
        googleIcon.centerY(inView: loginWithGoogleButtonLabel)
        googleIcon.anchor(left: loginWithGoogleButtonLabel.leftAnchor, paddingLeft: 15)
    }
    
}

