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
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.configTextField(leftTextfieldImage: UIImageView(image: #imageLiteral(resourceName: "ic_mail")))
        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
   
    @IBAction func sendLinkButtonPressed(_ sender: UIButton) {
        print("send link")
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
            navigationController?.popViewController(animated: true)
    }
    
}
