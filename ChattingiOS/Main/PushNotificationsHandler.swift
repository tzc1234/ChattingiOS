//
//  PushNotificationsHandler.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 02/04/2025.
//

@preconcurrency import UserNotifications
import UIKit

typealias UserID = Int

@MainActor
final class PushNotificationsHandler: NSObject, @preconcurrency UNUserNotificationCenterDelegate {
    var onReceiveNewContactNotification: ((UserID, Contact) -> Void)?
    var didReceiveMessageNotification: ((UserID, Contact) -> Void)?
    var willPresentMessageNotification: ((UserID, Contact) -> Void)?
    
    func setupPushNotifications() async {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let authorizationStatus = await center.notificationSettings().authorizationStatus
        switch authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge])
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    print("Notification permission denied.")
                }
            } catch {
                print("Notification permission request error: \(error)")
            }
        case .authorized:
            UIApplication.shared.registerForRemoteNotifications()
        default:
            print("Notification permission denied.")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        switch userInfo["action"] as? String {
        case "new_contact_added": handleNewContactNotification(userInfo: userInfo)
        case "message": handleDidReceiveMessageNotification(userInfo: userInfo)
        default: break
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        switch userInfo["action"] as? String {
        case "new_contact_added": handleNewContactNotification(userInfo: userInfo)
        case "message": handleWillPresentMessageNotification(userInfo: userInfo)
        default: break
        }
        return .init(rawValue: 0)
    }
    
    private func handleNewContactNotification(userInfo: [AnyHashable: Any]) {
        guard let (forUserID, contact) = contact(from: userInfo) else { return }
        
        onReceiveNewContactNotification?(forUserID, contact)
    }
    
    private func handleDidReceiveMessageNotification(userInfo: [AnyHashable: Any]) {
        guard let (forUserID, contact) = contact(from: userInfo) else { return }
        
        didReceiveMessageNotification?(forUserID, contact)
    }
    
    private func handleWillPresentMessageNotification(userInfo: [AnyHashable: Any]) {
        guard let (forUserID, contact) = contact(from: userInfo) else { return }
        
        willPresentMessageNotification?(forUserID, contact)
    }
    
    private func contact(from userInfo: [AnyHashable: Any]) -> (forUserID: Int, contact: Contact)? {
        guard let forUserID = userInfo["for_user_id"] as? UserID,
              let contactInfo = userInfo["contact"] as? [AnyHashable: Any],
              let contact = contactInfo.toContact() else {
            return nil
        }
        
        return (forUserID, contact)
    }
}

private extension [AnyHashable: Any] {
    func toContact() -> Contact? {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let contactResponse = try? decoder.decode(ContactResponse.self, from: data)
        return contactResponse?.toModel
    }
}
