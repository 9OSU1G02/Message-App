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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        print("sign up")
    }
    
    @IBAction func alreadyHaveAccountButtonPressed(_ sender: UIButton) {
        showLoginViewController()
    }
    
    private func showLoginViewController() {
        navigationController?.popViewController(animated: true)
    }
}
