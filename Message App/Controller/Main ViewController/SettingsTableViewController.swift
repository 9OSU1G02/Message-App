//
//  SettingsTableViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/28/20.
//

import UIKit
import ProgressHUD
class SettingsTableViewController: UITableViewController {
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        showUserInfo()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showUserInfo()
        
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //If not first section -> set heigh = 10
        return section == 0 ? 0 : 10
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //This go for header section (section-1, section-2,....)
        let headerView = UIView()
        return headerView
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    
    // MARK: - IBActions
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        FirebaseUserListener.shared.logOut { [weak self](error) in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
            }
            else {
                FirebaseRecentListener.shared.updateIsReceiverOnline(false)
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AuthNavitationController") as! UINavigationController
                loginVC.modalPresentationStyle = .fullScreen
                self?.present(loginVC, animated: true, completion: nil)
            }
        }
    }
    
    // MARK:  UpdateUI
    private func showUserInfo() {
        if let user = User.currentUser {
            usernameLabel.text = user.username
            statusLabel.text = user.status
            appVersionLabel.text = "App version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? 1.0)"
            if user.avatarLink != "" {
                //download(or get form locally if have ) and set avatar image
                FileStorage.downloadImage(imageUrl: user.avatarLink) { [weak self](avatarImage) in
                    self?.avatarImage.image = avatarImage?.circleMasked
                }
            }
        }
    }
}
