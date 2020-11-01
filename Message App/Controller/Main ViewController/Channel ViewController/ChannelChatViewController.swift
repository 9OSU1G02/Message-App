//
//  ChannelChatViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import UIKit
import MessageKit
import Gallery
import InputBarAccessoryView
//Realm (a local data just like coreData) to save message
import RealmSwift
import ProgressHUD
//MessagesViewController : from MessageKit
class ChannelChatViewController: MessagesViewController {
    // MARK:  Properties
    var channel: Channel!
    var gallery: GalleryController!
    let lefBarButtonView: UIView = {
       let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        return view
    }()
    

    private var chatRoomId = ""
    private var recepientId = ""
    private var recipientName = ""
    private var refreshControl = UIRefreshControl()
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    let micButton : InputBarButtonItem = InputBarButtonItem()
    var mkMessages: [MKMessage] = []
    var allLocalMessage: Results<LocalMessage>!
    let realm = try! Realm()
    
    var displayingMessagesCount = 0
    
    var maxMessageNumber = 0
    var minMessageNumber = 0
    //var typingCounter = 0
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    //Listener
    var notificationToken: NotificationToken?
    // MARK: - Listener
    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName = ""
    var audioDuration: Date!
    // MARK:  Inits
    init(channel: Channel) {
        super.init(nibName: nil, bundle: nil)
        self.chatRoomId = channel.id
        //Doesn't matter
        self.recepientId = channel.id
        self.recipientName = channel.name
        self.channel = channel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    // MARK:  LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLeftBarButton()
        configureCustomTitle()
        configureMessageCollectionView()
        configureGestureRecogniezer()
        configureMessageInputBar()
        
        loadChats()
        listenForNewChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatRoomId)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Stop audio playing and reset unread message when user leave chat room
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatRoomId)
        audioController.stopAnyOngoingPlaying()
    }
    // MARK: - Navigation
    
    // MARK:  Configurations
    
    private func configureMessageCollectionView() {
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        //Scroll to bottom of chat diolog when trigger input bar
        scrollsToBottomOnKeyboardBeginsEditing = true
        
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshControl
    }
    
    private func configureGestureRecogniezer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        //Delay when touch began
        longPressGesture.delaysTouchesBegan = true
    }
    
    private func configureMessageInputBar() {
        //Only show inputbar for admin
        messageInputBar.isHidden = channel.adminId != User.currentId
        
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: true)
        attachButton.onTouchUpInside { (item) in
            //Show actionSheet
            self.actionAttachButton()
        }
        
        micButton.image = UIImage(systemName: "mic.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: true)
        updateMicButtonStatus(show: true)
        
        micButton.addGestureRecognizer(longPressGesture)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: true)
        //StackView have 36 point : 3 point left, 30point for attachButton, 3 point right
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: true)
        //Disable paste image to inputbar
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        messageInputBar.backgroundView.backgroundColor = .systemBackground
    }
    
    private func configureLeftBarButton() {
        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonPressed))]
    }
    
    private func configureCustomTitle() {
        title = channel.name
    }
    
    func updateMicButtonStatus(show: Bool) {
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        }
        else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    // MARK:  Load Chats
    private func loadChats() {
        /* format : "CHAT_ROOM_ID" exactly the same with chatRoomId in LocalMessage, %@ == value of chatRoomId
         --> We want prediacte to be where chat room == chatRoomId
         */
        let predicate = NSPredicate(format: "\(CHAT_ROOM_ID) = %@", chatRoomId)
        
        //Get all message blong chatRoomID then sort them by date
        allLocalMessage = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: DATE,ascending: true)
        
        //Check message in local Database (realm) if don't have go to firebase also check for message if have message so download it and save to database
        if allLocalMessage.isEmpty {
            checkForOldChats()
        }
        //Observer realm data
        notificationToken = allLocalMessage.observe({ (changes: RealmCollectionChange) in
            //Code will run when something change in database
            switch changes {
            //Trigger when some thing query to out database
            case .initial(_):
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: false)
            //Trigger when we something new inserted to local data
            case .update(_,_,let inserttions, _):
                    for index in inserttions {
                        //Insert to mkMessages
                        self.insertMessage(self.allLocalMessage[index])
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom(animated: false)
                }
            case .error(let error):
                print("Error on new insertion",error.localizedDescription)
            }
        })
    }
    
    //get message form firebase which have date came after the last date of message in local database then save it local database
    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(chatRoomId, collectionId: chatRoomId, lastMessageDate: lastMessageDate())
    }
    
    //go to firebase also check for message if have message so download it and save to database
    private func checkForOldChats() {
        FirebaseMessageListener.shared.checkForOldChat(chatRoomId, collectionId: chatRoomId)
    }
    
    // MARK: - Insert Message
    

    
    private func insertMessages() {
       // oldest message: min----max min----max min---->max: last message , every time we want to get 12 message (from min to max ) to display
        maxMessageNumber = allLocalMessage.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - 12
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessage[i])
        }
    }
    
    //Conver LocalMessage to MKMessage then append to mkMessages
    private func insertMessage(_ localMessage: LocalMessage) {
        //ONly update status for message not from current user
        if localMessage.senderId != User.currentId {
            markMessageAsRead(localMessage)
        }
        //_collectionView: self : e.g: went we sen picture, we want to ask this collectionView(here is sefl: ChatViewController) to reload to show image
        let incoming  = IncomingMessage(messageCollectionView: self)
        mkMessages.append(incoming.createMKMessage(localMessage: localMessage)!)
        
        #warning("increase displayingMessagesCount every time 1 message is display")
        displayingMessagesCount += 1
    }
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        /* Min
         |
         |
         Max

         Min
         |
         |
         |
         Max

         Min
         |
         |
         |
         Max*/
        
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - 12
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        //Revert because we want Insert new MaxMessage right after old MinMessage
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            insertOlderMessage(allLocalMessage[i])
        }
    }
    
    private func insertOlderMessage(_ localMessage: LocalMessage) {
        //_collectionView: self : e.g: went we sen picture, we want to ask this collectionView(here is sefl: ChatViewController) to reload to show image
        let incoming  = IncomingMessage(messageCollectionView: self)
        //Insert message new max message right after old minMessage
        /* Min
         |
         |
         Max

         Min
         |
         |
         |
         Max

         Min
         |
         |
         |
         Max*/
        mkMessages.insert(incoming.createMKMessage(localMessage: localMessage)!, at: 0)
        
        #warning("increase displayingMessagesCount every time 1 message is display")
        displayingMessagesCount += 1
    }
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        // when user open chatroom, check if message from another user and have Sent status -> update message on firebase status to Read
        if localMessage.senderId != User.currentId && localMessage.status != READ {
            FirebaseMessageListener.shared.updateMessageInFireBase(localMessage, memberIds: [User.currentId,recepientId])
        }
    }
    // MARK:  Actions
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        OutgoingMessage.sendChannel(channel: channel, text: text, photo: photo, video: video, audio: audio, location: location)
        
    }
    
    @objc func backButtonPressed() {
        //when user exit chat room we will reset unread message to 0
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatRoomId)
        // - Remove listener because we don't want to get new chat save in realm when user is no longer in the chat view
        removeListener()
        navigationController?.popViewController(animated: true)
    }
    
    private func actionAttachButton() {
        //Hide the keyboard when show actionSheet
        messageInputBar.inputTextView.resignFirstResponder()
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
            self.showImageGallery(camera: true)
        }
        let shareMedia = UIAlertAction(title: "Library", style: .default) { (alert) in
            self.showImageGallery(camera: false)
        }
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (alert) in
            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: LOCATION)
            }
            else {
                print("no access to location")
            }
        }
        //forKey: must be "image"
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        present(optionMenu, animated: true, completion: nil)
    }
    
    
    // MARK: - UIScrollViewDelegate
    //Trigger when scrolling movement comes to a halt( begin Refreshing )
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            if displayingMessagesCount < allLocalMessage.count {
                // load early messages
                loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Update Read Message Status
    //update local message have indentical id with message on fb (have Read status)
    private func updateMessage(_ localMessage: LocalMessage) {
        for index in 0 ..< mkMessages.count {
            let tempMessage = mkMessages[index]
            if localMessage.id == tempMessage.messageId {
                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.readDate
                RealmManager.shared.saveToRealm(localMessage)
                if mkMessages[index].status == READ {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func removeListener() {
        FirebaseMessageListener.shared.removeListener()
    }
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessage.last?.date ?? Date()
        return lastMessageDate
    }
    
    // MARK: - Gallery
    private func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        //Show 2 tab : image and camere (Config from Gallary pod)
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab,.videoTab]
        //Limit image can choose = 1
        Config.Camera.imageLimit = 1
        //Default tap when we open gallery
        Config.initialTab = .imageTab
        //Video long maxium is 30s
        Config.VideoEditor.maximumDuration = 30
        self.present(gallery, animated: true, completion: nil)
    }
    
    // MARK: - Audio Messages
    @objc func recordAudio() {
        switch longPressGesture.state {
        //When user hold 0.5 s
        case .began:
            audioDuration = Date()
            audioFileName = Date().stringDate()
            // start recording
            AudioRecoder.shared.startRecording(fileName: audioFileName)
        
        //User realsed finger
        case .ended:
            //stop recording
            AudioRecoder.shared.finishRecording()
            //Check if audio has successfully save in local or not
            if fileExistAtPath(path: audioFileName + ".m4a") {
                //How many second passed from audioDuration to Date()--current
                let audioD = audioDuration.interval(ofComponent: .second, from: Date())
                //send message
                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName,location: nil, audioDuration: audioD)
            }
            else {
                print("no audio file")
            }
            //Clean audioFileName for next recording
            audioFileName = ""
        @unknown default:
            print("unkown")
        }
        
    }
}

// MARK: -  Gallery DElegate
extension ChannelChatViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            //convert Image(class) to UIImage
            images.first!.resolve { (image) in
                // Upload Image
                if image != nil {
                    self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
                }
                else {
                    ProgressHUD.showError("Couldnt select image!")
                }
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
