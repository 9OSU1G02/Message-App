//
//  ChatViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/29/20.
//

import UIKit
import MessageKit
import Gallery
import InputBarAccessoryView
//Realm (a local data just like coreData) to save local message
import RealmSwift
import ProgressHUD

class ChatViewController: MessagesViewController {
    // MARK:  Properties
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser?.username ?? "?")
    var mkMessages : [MKMessage] = []
    var allLocalMessage: Results<LocalMessage>!
    let realm = try! Realm()
    
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var typingCounter = 0
    
    var audioFileName = ""
    var audioDuration: Date!
    
    private var chatRoomId = ""
     var recepientId = ""
    private var recipientName = ""
    private var refreshControl = UIRefreshControl()
    
    var gallery: GalleryController!
    let micButton : InputBarButtonItem = InputBarButtonItem()
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    // MARK: - Realm Listener
    var notificationToken: NotificationToken?
    
    // MARK: - Gesture
    var longPressGesture: UILongPressGestureRecognizer!
    
    let lefBarButtonView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        return view
    }()
    let titleLable: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        title.textColor = .green
        return title
    }()
    let subTitleLable: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true
        subTitle.textColor = .purple
        return subTitle
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createTypingObserver()
        configureLeftBarButton()
        configureCustomTitle()
        configureMessageCollectionView()
        configureGestureRecogniezer()
        
        configureMessageInputBar()
        
        
        
        loadChats()
        listenForNewChats()
        listenforReadStatusChange()
    }
    deinit {
        print("Deinit chat view controller")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatRoomId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatRoomId)
        audioController.stopAnyOngoingPlaying()
    }
    // MARK:  Inits
    init(chatRoomId: String, recepientId: String, recipientName:String) {
        super.init(nibName: nil, bundle: nil)
        self.chatRoomId = chatRoomId
        self.recepientId = recepientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - pull to load handle
    
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
        let incoming  = IncomingMessage(_collectionView: self)
        
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
        
        //Insert message new max message right after old minMessage
        mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        
        //warning("increase displayingMessagesCount every time 1 message is display")
        displayingMessagesCount += 1
    }
    
    private func listenforReadStatusChange() {
        //When another user reading our messages, our message is being updated--> we want get thoese messge from firebase
        FirebaseMessageListener.shared.listenForReadStatusChange(User.currentId, collectionId: chatRoomId) { (updatedMessage) in
            
            //Find message in local database which have id identical with message we got from firebase(have Read status, we don't want message have Sent status be cause it already in local data) then change status and date of message local == message on firebase
            if updatedMessage.status != SENT {
                self.updateMessage(updatedMessage)
            }
        }
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        // when user open chatroom, check if message from another user and have Sent status -> update message on firebase status to Read
        if localMessage.senderId != User.currentId && localMessage.status != READ {
            FirebaseMessageListener.shared.updateMessageInFireBase(localMessage, memberIds: [User.currentId,recepientId])
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
    
    // MARK:  Actions
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        OutgoingMessage.send(chatRoomId: chatRoomId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration ,location: location, memberIds: [User.currentId, recepientId])
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
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) {[weak self] (alert) in
            guard let self = self else { return }
            self.showImageGallery(camera: true)
        }
        let shareMedia = UIAlertAction(title: "Library", style: .default) {[weak self] (alert) in
            guard let self = self else { return }
            self.showImageGallery(camera: false)
        }
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) {[weak self] (alert) in
            guard let self = self else { return }
            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: LOCATION)
            }
            else {
                ProgressHUD.showError("no access to location")
            }
        }
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        
        //forKey: must be "image"
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        present(optionMenu, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    private func removeListener() {
        // Remmove listener
        FirebaseMessageListener.shared.removeListener()
        FirebaseTypingListener.shared.removeTypingListener()
    }
    
    //Get date of last local message if available , if not take current date
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessage.last?.date ?? Date()
        return lastMessageDate
    }
    
    // MARK: - Update Typing indicator
    func createTypingObserver() {
        FirebaseTypingListener.shared.createTypingObserver(chatRoomId: chatRoomId) {[weak self] (isTyping) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateTypingIndicator(isTyping)
            }
        }
    }
    
    func typingIndicatorUpdate() {
        //Current User is Typing
        typingCounter += 1
        FirebaseTypingListener.saveTypingCounter(typing: true, chatRoomId: chatRoomId)
        
        //affter 1.5s change isTyping to false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            //Stop typing
            self.typingCounterStop()
        }
    }
    
    func typingCounterStop() {
        typingCounter -= 1
        if typingCounter == 0 {
            FirebaseTypingListener.saveTypingCounter(typing: false, chatRoomId: chatRoomId)
        }
    }
    
    func updateTypingIndicator(_ show: Bool) {
        subTitleLable.text = show ? "Typing..." : ""
    }
    
    // MARK: - Configuration
    
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
    
    private func configureMessageInputBar() {
        //InputBarAccessoryViewDelegate
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: true)
        attachButton.onTouchUpInside { [weak self] (item) in
            guard let self = self else { return }
            // Show Action sheet
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
    
    private func configureGestureRecogniezer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        //Delay when touch began
        longPressGesture.delaysTouchesBegan = true
    }
    
    private func configureLeftBarButton() {
        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonPressed))]
    }
    
    private func configureCustomTitle() {
        lefBarButtonView.addSubview(titleLable)
        lefBarButtonView.addSubview(subTitleLable)
        let lefBarButtonItem = UIBarButtonItem(customView: lefBarButtonView)
        navigationItem.leftBarButtonItems?.append(lefBarButtonItem)
        titleLable.text = recipientName
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
            FirebaseMessageListener.shared.checkForOldChat(User.currentId, collectionId: chatRoomId)
        }
        //add observe to allLocalMessage, if new massage send or recived , that message will save in realm , because ealm provides you with live objects so allLocalMessage will also have new massage send or recived
        notificationToken = allLocalMessage.observe({[weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            //Code will run when something change in allLocalMessage
            switch changes {
            //Trigger when some thing query to out database ( user enter chat room)
            case .initial(_):
                //Convert all local message in allLocalMessage to MKMessage then append to mkMessages to show in chatview
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: false)
            //Trigger when we something new (new local message) inserted to local data
            case .update(_,_,let inserttions, _):
                // inserttions : array of index of new massge was save in realm
                //index : index of new massge was save in realm --> is the same with index of new message in allLocalMessage because allLocalMessage and realm have euqual message blong to chatroom id ( read line 116)
                // e.g : if message was save have index in realm is 4 -> is also have index 4 in allLocalMessage
                for index in inserttions {
                    //Convert new local message to MKMessage then Insert to mkMessages
                    self.insertMessage(self.allLocalMessage[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }
            case .error(let error):
                print("Error on new insertion",error.localizedDescription)
            }
        })
    }
    
    // MARK: - Get New Chat
    //get message form firebase which have date came after the last date of message in local database and NOT sent by current user then save it to realm
    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatRoomId, lastMessageDate: lastMessageDate())
    }
    
    // MARK: - Insert Messages
    //Convert all local message in allLocalMessage to MKMessage then append to mkMessages
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
    
    //Conver 1 Local Message to MKMessage then append to mkMessages
    private func insertMessage(_ localMessage: LocalMessage) {
        //ONly update status for message not from current user
        if localMessage.senderId != User.currentId {
        markMessageAsRead(localMessage)
        }
        //_collectionView: self : e.g: went we sen picture, we want to ask this collectionView(here is sefl: ChatViewController) to reload to show image
        let incoming  = IncomingMessage(_collectionView: self)
        mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        
        //warning("increase displayingMessagesCount every time 1 message is display")
        displayingMessagesCount += 1
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
    
    // MARK: - UIScrollViewDelegate
    //Trigger when scrolling movement comes to a halt( begin Refreshing )
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            if displayingMessagesCount < allLocalMessage.count {
                // - load early messages
                loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshControl.endRefreshing()
        }
    }
}

extension ChatViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            //convert Image(class) to UIImage
            images.first!.resolve { [weak self] (image) in
                guard let self = self else { return }
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
