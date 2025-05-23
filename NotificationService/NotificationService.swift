//
//  NotificationService.swift
//  NotificationService
//
//  Created by Tsz-Lung on 05/04/2025.
//

import UserNotifications
import UIKit
import Intents

final class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    private lazy var cacheStore = try? CoreDataMessagesStore(url: DefaultMessageStoreURL.url)
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent else { return contentHandler(request.content) }
        guard let userInfo = bestAttemptContent.userInfo as? [String: Any],
              let action = userInfo["action"] as? String else {
            return contentHandler(bestAttemptContent)
        }
        
        switch action {
        case "new_contact_added", "message":
            guard let contactInfo = userInfo["contact"] as? [String: Any],
                  let contactID = contactInfo["id"] as? Int,
                  let responderInfo = contactInfo["responder"] as? [String: Any],
                  let senderName = responderInfo["name"] as? String else {
                return contentHandler(bestAttemptContent)
            }
            
            let prefix = action == "message" ? "message" : "contact"
            update(
                with: senderName,
                avatarURLString: responderInfo["avatar_url"] as? String,
                conversationID: "\(prefix)-\(contactID)",
                on: bestAttemptContent,
                contentHandler: contentHandler
            )
        default:
            contentHandler(bestAttemptContent)
        }
    }
    
    private func update(with senderName: String,
                        avatarURLString: String?,
                        conversationID: String,
                        on content: UNMutableNotificationContent,
                        contentHandler: @escaping (UNNotificationContent) -> Void) {
        if let avatarURLString, let avatarURL = URL(string: avatarURLString) {
            retrieveImage(from: avatarURL) { [weak self] senderImage in
                self?.update(
                    with: senderName,
                    senderImage: senderImage,
                    conversationID: conversationID,
                    on: content,
                    contentHandler: contentHandler
                )
            }
        } else {
            update(
                with: senderName,
                senderImage: .defaultSenderImage,
                conversationID: conversationID,
                on: content,
                contentHandler: contentHandler
            )
        }
    }
    
    private func update(with senderName: String,
                        senderImage: INImage?,
                        conversationID: String,
                        on content: UNMutableNotificationContent,
                        contentHandler: @escaping (UNNotificationContent) -> Void) {
        let senderHandle = INPersonHandle(value: senderName, type: .unknown)
        let sender = INPerson(
            personHandle: senderHandle,
            nameComponents: nil,
            displayName: content.title,
            image: senderImage,
            contactIdentifier: nil,
            customIdentifier: nil
        )
        
        let intent = INSendMessageIntent(
            recipients: nil,
            outgoingMessageType: .outgoingMessageText,
            content: content.body,
            speakableGroupName: nil,
            conversationIdentifier: conversationID,
            serviceName: nil,
            sender: sender,
            attachments: nil
        )
        intent.setImage(senderImage, forParameterNamed: \.sender)
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .incoming
        interaction.donate { error in
            guard error == nil else { return contentHandler(content) }
            
            do {
                let updatedContent = try content.updating(from: intent)
                contentHandler(updatedContent)
            } catch {
                contentHandler(content)
            }
        }
    }
    
    private func retrieveImage(from url: URL, completion: @escaping (INImage?) -> Void) {
        Task { [weak self] in
            guard let self else { return }
            guard let cachedImageData = try? await cacheStore?.retrieveImageData(for: url) else {
                return downloadImage(from: url, completion: completion)
            }
            
            completion(INImage(imageData: cachedImageData))
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (INImage?) -> Void) {
        // Supports background download.
        URLSession.shared.downloadTask(with: url) { [weak self] tempURL, _, error in
            guard let tempURL, error == nil, let imageData = try? Data(contentsOf: tempURL) else {
                return completion(.defaultSenderImage)
            }
            
            self?.cacheImageData(imageData, for: url)
            completion(INImage(imageData: imageData))
        }
        .resume()
    }
    
    private func cacheImageData(_ data: Data, for url: URL) {
        guard !data.isEmpty, let cacheStore else { return }
        
        Task { try? await cacheStore.saveImageData(data, for: url) }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

private extension INImage {
    convenience init?(systemName: String) {
        guard let imageData = UIImage(systemName: systemName)?.pngData() else { return nil }
        
        self.init(imageData: imageData)
    }
    
    static var defaultSenderImage: INImage? {
        INImage(systemName: "person.circle")
    }
}
