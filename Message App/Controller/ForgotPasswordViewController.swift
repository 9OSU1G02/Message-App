//
//  ForgotPasswordViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/27/20.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    // MARK: - IBOutlet
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendLinkButtonTextField: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNotificationObservers()
        configureUI()
    }
    
    // MARK: - IBActions
   
    @IBAction func sendLinkButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
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
    }
    func configureUI() {
        emailTextField.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "ic_mail")))
    }
}

extension ForgotPasswordViewController: AuthenticationFormCheck {
    func updateForm(formIsValid: Bool) {
        if formIsValid {
            sendLinkButtonTextField.alpha = 1
            sendLinkButtonTextField.isEnabled = true
        }
        else {
            sendLinkButtonTextField.alpha = 0.3
            sendLinkButtonTextField.isEnabled = false
        }
    }
            
    func checkFormIsValid() -> Bool {
        return emailTextField.text != ""
    }
}
