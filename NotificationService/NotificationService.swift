//
//  NotificationService.swift
//  NotificationService
//
//  Created by Tsz-Lung on 05/04/2025.
//

import UserNotifications
import Intents

final class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent else { return contentHandler(request.content) }
        
        guard let userInfo = bestAttemptContent.userInfo as? [String: Any],
              let contactInfo = userInfo["contact"] as? [String: Any],
              let contactID = contactInfo["id"] as? Int,
              let responderInfo = contactInfo["responder"] as? [String: Any],
              let senderName = responderInfo["name"] as? String,
              let avatarURLString = responderInfo["avatar_url"] as? String,
              let avatarURL = URL(string: avatarURLString) else {
            return contentHandler(bestAttemptContent)
        }
        
        downloadImage(from: avatarURL) { imageURL in
            guard let imageURL, let imageData = try? Data(contentsOf: imageURL) else {
                return contentHandler(bestAttemptContent)
            }
            
            let senderHandle = INPersonHandle(value: senderName, type: .unknown)
            let senderImage = INImage(imageData: imageData)
            let sender = INPerson(
                personHandle: senderHandle,
                nameComponents: nil,
                displayName: senderName,
                image: senderImage,
                contactIdentifier: nil,
                customIdentifier: nil
            )
            
            let intent = INSendMessageIntent(
                recipients: nil,
                outgoingMessageType: .outgoingMessageText,
                content: bestAttemptContent.body,
                speakableGroupName: nil,
                conversationIdentifier: "contact-\(contactID)",
                serviceName: nil,
                sender: sender,
                attachments: nil
            )
            intent.setImage(senderImage, forParameterNamed: \.sender)
            
            let interaction = INInteraction(intent: intent, response: nil)
            interaction.direction = .incoming
            interaction.donate { error in
                guard error == nil else { return contentHandler(bestAttemptContent) }
                
                do {
                    let updatedContent = try bestAttemptContent.updating(from: intent)
                    contentHandler(updatedContent)
                } catch {
                    contentHandler(bestAttemptContent)
                }
            }
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (URL?) -> Void) {
        // Supports background download.
        URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL, error == nil else { return completion(nil) }
            
            let destinationURL = URL.temporaryDirectory.appending(component: url.lastPathComponent)
            try? FileManager.default.moveItem(at: tempURL, to: destinationURL)
            completion(destinationURL)
        }
        .resume()
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
