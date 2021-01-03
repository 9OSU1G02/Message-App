//
//  AddChannelTableViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import UIKit
import Gallery
import ProgressHUD
class AddChannelTableViewController: UITableViewController {
    // MARK: - Properties
    var gallery: GalleryController!
    var tapGesture = UITapGestureRecognizer()
    var avatarLink = ""
    var channelId = UUID().uuidString
    var channelToEdit: Channel?
    // MARK: - IBOutlet
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        configureGesture()
        //In editing mode
        if channelToEdit != nil {
            configureEditingView()
        }
        configureLeftBarButton()
    }
    
    deinit {
        print("Deinit addchannel vc")
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        // Name of channel is compulsory
        if nameTextField.text != "" {
            channelToEdit != nil ? editChannel() : saveChannel()
        }
        else {
            ProgressHUD.showError("Channel name is empty!")
        }
    }
    
    // MARK: - Configuration
    private func configureGesture() {
        tapGesture.addTarget(self, action: #selector(avatarImageTap))
        //allow user can tap to avatar to trigger tapGesture
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.turn.down.left"), style: .plain, target: self, action: #selector(backButtonPressed))
    }
    
    private func configureEditingView() {
        nameTextField.text = channelToEdit!.name
        channelId = channelToEdit!.id
        aboutTextView.text = channelToEdit!.aboutChannel
        avatarLink = channelToEdit!.avatarLink
        title = channelToEdit!.name
        setAvatar(avatarLink: channelToEdit!.avatarLink)
    }
    
   
    
    // MARK: - Selectors
    @objc func avatarImageTap() {
        showGallery()
    }
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Save Channel
    private func saveChannel() {
        let channel = Channel(id: channelId, name: nameTextField.text!, adminId: User.currentId, memberIds: [User.currentId], avatarLink: avatarLink, aboutChannel: aboutTextView.text)
        
        // save channel to firebase
        FirebaseChannelListener.shared.saveChannel(channel)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func editChannel() {
        channelToEdit!.name = nameTextField.text!
        channelToEdit!.aboutChannel = aboutTextView.text
        channelToEdit?.avatarLink = avatarLink
        // save channel to firebase
        FirebaseChannelListener.shared.saveChannel(channelToEdit!)
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Gallery
    
    private func showGallery() {
        gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        present(gallery, animated: true, completion: nil)
    }
    
    private func uploadAvatarIcon(_ image: UIImage) {
        let fileDirectory = "Avatars/" + "_\(channelId)" + ".jpg"
        FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: channelId)
        FileStorage.uploadImage(image, directory: fileDirectory) { [weak self](avatarLink) in
            guard let self = self else { return }
            self.avatarLink = avatarLink ?? ""
        }
    }
    func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) {[weak self] (avatarImage) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
        else {
            self.avatarImageView.image = UIImage(named: AVATAR_DEFAULT_IMAGE)
        }
    }
    
}

// MARK: - Extension
extension AddChannelTableViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            //Convert to UIimage
            images.first!.resolve { [weak self](icon) in
                guard let self = self else { return }
                if icon != nil {
                    //upload image
                    self.uploadAvatarIcon(icon!)
                    //set avatar image
                    self.avatarImageView.image = icon?.circleMasked
                    
                }
                else {
                    ProgressHUD.showFailed("Coldn't select image!")
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

