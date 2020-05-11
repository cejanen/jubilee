//
//  ViewController.swift
//  com.commemoratemessenger
//
//  Created by Tomas Cejka on 3/30/20.
//  Copyright © 2020 CJ. All rights reserved.
//

import UIKit
import MessageKit

final class ChatViewController: MessagesViewController {
    private lazy var dataLoader = DataLoader()
    private var messages: [Message] = [] {
        didSet {
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToBottom()
            storeLastViewedDate(date: messages.last?.sentDate)
        }
    }

    private lazy var userDefaultsManager = UserDefaultsManager()
    private lazy var notificationScheduler = LocalNotificationScheduler()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d.M.yyyy"
        //        "Úterý 27.5.2014"
        return dateFormatter
    }()
    private lazy var timeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    private var isPlaying = false
    private var lastDate: Date? = nil
    private var added = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        messages = dataLoader.loadDataUntil(date: userDefaultsManager.lastOpenMessageDate())
        messageInputBar.isHidden = true
        title = "Jubilee"

        createPlayView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        resetNotifToLastMessage()
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        Sender(displayName: "Misa")
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let messageOrig = messages[indexPath.section]
        return NSAttributedString(string: "\(timeFormatter.string(from: message.sentDate)) \(messageOrig.type.text)", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section == 0 {
            return NSAttributedString(string: dateFormatter.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        }
        let previousIndexPath = IndexPath(row: 0, section: indexPath.section - 1)
        let previousMessage = messageForItem(at: previousIndexPath, in: messagesCollectionView)
        if message.sentDate.isInSameDayOf(date: previousMessage.sentDate){
            return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        }

        return NSAttributedString(string: dateFormatter.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesLayoutDelegate {
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        section == 0 ? CGSize(width: 100, height: 10) : .zero
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        15
    }

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section == 0 {
            return 20
        }
        let previousIndexPath = IndexPath(row: 0, section: indexPath.section  - 1)
        let previousMessage = messageForItem(at: previousIndexPath, in: messagesCollectionView)
        if message.sentDate.isInSameDayOf(date: previousMessage.sentDate){
            return 5
        }

        return 20
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let originalMessage = messages[indexPath.section]
        switch (originalMessage.isMyMessage, originalMessage.type) {
        case (true, .messenger):
            return .incomingGray
        case (true, .sms):
            return .incomingGrayDarker
        case (false, .messenger):
            return .outgoingGreenLighter
        case (false, .sms):
            return .outgoingGreen
        }
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDisplayDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let message = messages[indexPath.section]
        avatarView.image = message.isMyMessage ? UIImage(named: "Radek") : UIImage(named: "Misa")
    }
}

// MARK: - Help methods
private extension ChatViewController {
    func resetNotifToLastMessage() {
        // clean up notifications
        UIApplication.shared.applicationIconBadgeNumber = 0
        notificationScheduler.cancelAllScheduledRequests()
        notificationScheduler.cancelAllScheduledRequests()
        guard let lastMessage = messages.last else {
            return
        }
        guard let newMessage = dataLoader.nextMessage(after: lastMessage) else {
            return
        }
        notificationScheduler.scheduleNextMessage(message: newMessage)
    }

    func storeLastViewedDate(date: Date?) {
        print("storeLastViewedDate \(date)")
        userDefaultsManager.storeLastOpenMessageDate(date: date ?? Date())
    }

    func createPlayView() {
        let playView = UIView()
        playView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(playView)

        playView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        playView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let playImageButton = UIButton()
        playImageButton.translatesAutoresizingMaskIntoConstraints = false
        playImageButton.setImage(UIImage(systemName: "play"), for: .normal)
        playImageButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        playView.addSubview(playImageButton)
        playImageButton.centerXAnchor.constraint(equalTo: playView.centerXAnchor).isActive = true
        playImageButton.centerYAnchor.constraint(equalTo: playView.centerYAnchor).isActive = true
        playImageButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        playImageButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }

    @objc func playTapped() {

        guard !isPlaying else {
            return
        }

        isPlaying.toggle()
        lastDate = messages.last?.sentDate

        addNewMessage()
    }

    @objc func addNewMessage() {
        // check original last date is set
        guard let lastDate = lastDate else {
            return
        }

        // check if there is next message
        guard let nextMessage = dataLoader.nextMessage(after: messages.last!) else {
            return
        }

        // compare dates in one hour
        let difference = nextMessage.sentDate.timeIntervalSince1970 - lastDate.timeIntervalSince1970
        if difference <= 3600 {
            // add new message
            messages.append(nextMessage)
            added = true
            let delay = Double(messages.last!.text.count) * 0.13
            perform(#selector(addNewMessage), with: nil, afterDelay: delay)
        } else {
            // add new message
            if !added {
                messages.append(nextMessage)
            }
            added = false
            isPlaying.toggle()
            self.lastDate = nil
            self.resetNotifToLastMessage()
        }
    }
}
