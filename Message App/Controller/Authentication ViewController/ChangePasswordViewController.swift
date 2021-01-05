//
//  ChangePasswordViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 1/4/21.
//

import UIKit
import ProgressHUD
class ChangePasswordViewController: UIViewController {
    var signInMethod: SignInMethod!
    override func viewDidLoad() {
        super.viewDidLoad()
        configTextField()
        configureNotificationObservers()
        setupBackgroundTap()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    @IBOutlet weak var changePasswordLabel: UIButton!
    
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        
        guard let newPassword = newPasswordTextField.text,
              let repeatPassword = confirmNewPasswordTextField.text,
              newPassword == repeatPassword
        else {
            ProgressHUD.showError("Password not match")
            return
        }
        
        switch signInMethod {
        case .email:
            guard let oldPassword = oldPasswordTextField.text else { return }
            FirebaseUserListener.shared.changePassword(signInMethod: .email, oldPassword: oldPassword, newPassword: newPassword) { [weak self]isSuccess in
                guard let self = self else { return}
                if isSuccess {
                    ProgressHUD.showSuccess("Succeed Change Password")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        case .google:
            FirebaseUserListener.shared.changePassword(signInMethod: .google, newPassword: newPassword) { [weak self]isSuccess in
                guard let self = self else { return}
                if isSuccess {
                    ProgressHUD.showSuccess("Succeed Change Password")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        case .none:
            break
        }
        
    }
    deinit {
        print("Denit changpassword")
    }
    func configTextField() {
        SignInMethod.getSignInMethod { (result) in
            switch result {
            case .success(let method):
                signInMethod = method
                if method == .email {
                    oldPasswordTextField.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "Key")))
                }
                else {
                    oldPasswordTextField.isHidden = true
                }
                
            case .failure(let error):
                print(error.rawValue)
                
            }
        }
        newPasswordTextField.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "Key")))
        confirmNewPasswordTextField.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "Key")))
    }
    
    func configureNotificationObservers() {
        oldPasswordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        newPasswordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        confirmNewPasswordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    // MARK: - Selections
    @objc func textDidChange(_ sender: UITextField) {
        let formIsValid = checkFormIsValid()
        updateForm(formIsValid: formIsValid)
    }
    
}

extension ChangePasswordViewController: AuthenticationFormCheck {
    func updateForm(formIsValid: Bool) {
        if formIsValid {
            changePasswordLabel.alpha = 1
            changePasswordLabel.isEnabled = true
            
        }
        else {
            changePasswordLabel.alpha = 0.3
            changePasswordLabel.isEnabled = false
        }
    }
    
    func checkFormIsValid() -> Bool {
        return signInMethod == .email
            ? oldPasswordTextField.text != "" && newPasswordTextField.text != "" && confirmNewPasswordTextField.text != ""
            //When sign with google only check for newpassword and confrim newpassword
            : newPasswordTextField.text != "" && confirmNewPasswordTextField.text != ""
    }
}
