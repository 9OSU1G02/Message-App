//
//  SignUpViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/27/20.
//

import UIKit

class SignUpViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTexiField: UITextField!
    @IBOutlet weak var signUpButtonLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    // MARK: - IBActions
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func alreadyHaveAccountButtonPressed(_ sender: UIButton) {
        showLoginViewController()
    }
    
    private func showLoginViewController() {
        navigationController?.popViewController(animated: true)
    }
    // MARK: - Selections
    @objc func textDidChange(_ sender: UITextField) {
        let formIsValid = checkFormIsValid()
        updateForm(formIsValid: formIsValid)
    }
    // MARK: - Configuration
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        repeatPasswordTexiField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func configureUI() {
        emailTextField.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "ic_mail")))
        passwordTextField.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "Key")))
        repeatPasswordTexiField.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "Key")))
    }
}

// MARK: - Extension
extension SignUpViewController: AuthenticationFormCheck {
    func updateForm(formIsValid: Bool) {
        if formIsValid {
            signUpButtonLabel.alpha = 1
            signUpButtonLabel.isEnabled = true
        }
        else {
            signUpButtonLabel.alpha = 0.3
            signUpButtonLabel.isEnabled = false
        }
    }
            
    func checkFormIsValid() -> Bool {
        return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTexiField.text != ""
    }
}
