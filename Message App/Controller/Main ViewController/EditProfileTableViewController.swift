//
//  EditProfileTableViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/28/20.
//

import UIKit
import Gallery
import ProgressHUD
class EditProfileTableViewController: UITableViewController {
    var gallery: GalleryController!
    override func viewDidLoad() {
        super.viewDidLoad()
        showUserInfo()
                    }
    // MARK: - IBOutlet
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    
    // MARK: - IbActions
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        showImageGallery()
    }
    
    deinit {
        print("Deinit Edit Profile Viewcontroller")
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        if var user = User.currentUser,
           let username = usernameTextField.text, username != "",
           let phoneNumber = phoneNumberTextField.text, phoneNumber != "" {
            user.username = username
            user.status = statusTextField.text ?? ""
            user.phoneNumber = phoneNumber
            saveUserLocally(user)
            FirebaseUserListener.shared.saveUserToFirestore(user)
            FirebaseRecentListener.shared.updateRececiverInfomationOfRecent(user)
        }
        else {
            ProgressHUD.showFailed("Usename and Phone Number must fullfil")
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK:  UpdateUI
    func showUserInfo() {
        if let user = User.currentUser {
            usernameTextField.text = user.username
            statusTextField.text = user.status
            phoneNumberTextField.text = user.phoneNumber
            if user.avatarLink != "" {
                // set avatar
                FileStorage.downloadImage(imageUrl: user.avatarLink) {[weak self] (avatarImage) in
                    guard let self = self else { return }
                    self.avatarImage.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    
    // MARK:  Gallery
    
    func showImageGallery() {
        gallery = GalleryController()
        gallery.delegate = self
        //Show 2 tab : image and camere (Config from Gallary pod)
        Config.tabsToShow = [.imageTab,.cameraTab]
        //Limit image can choose = 1
        Config.Camera.imageLimit = 1
        //Default tap when we open gallery
        Config.initialTab = .imageTab
        present(gallery, animated: true, completion: nil)
    }
    // MARK:  UploadImages
    private func uploadAvatarImage(_ image: UIImage) {
        //Save image in Avatars folder , file name = "_\(User.currentId)" + ".jpg" (Firestore)
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        
        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            if var user = User.currentUser {
                user.avatarLink = avatarLink ?? ""
                saveUserLocally(user)
                FirebaseUserListener.shared.saveUserToFirestore(user)
            }
            // Save Image locally
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: User.currentId)
        }
    }
    
    // MARK: - TableView DataSource & delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //If not first section -> set heigh = 10
        return section == 0 ? 0 : 10
    }
        
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //This go for header section (section-1, section-2,....)
        let headerView = UIView()
        
        return headerView
    }
}
// MARK: - Extension

extension EditProfileTableViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            //convert Image(class) to UIImage
            images.first!.resolve { [weak self](avatarUIImage) in
                guard let self = self else { return }
                // Upload Image
                if avatarUIImage != nil {
                    self.uploadAvatarImage(avatarUIImage!)
                    self.avatarImage.image = avatarUIImage?.circleMasked
                }
                else {
                    ProgressHUD.showError("Couldnt select image!")
                }
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
