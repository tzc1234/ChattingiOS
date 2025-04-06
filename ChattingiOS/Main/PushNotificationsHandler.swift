//
//  PushNotificationsHandler.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 02/04/2025.
//

@preconcurrency import UserNotifications
import UIKit

@MainActor
final class PushNotificationsHandler: NSObject, @preconcurrency UNUserNotificationCenterDelegate {
    var onReceiveNewContactAddedNotification: ((Int, Contact) -> Void)?
    
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
        performActionAfterReceivedNotification(userInfo: userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        performActionAfterReceivedNotification(userInfo: userInfo)
        return .init(rawValue: 0)
    }
    
    private func performActionAfterReceivedNotification(userInfo: [AnyHashable: Any]) {
        let action = userInfo["action"] as? String
        switch action {
        case "new_contact_added":
            if let forUserID = userInfo["for_user_id"] as? Int,
               let contactInfo = userInfo["contact"] as? [AnyHashable: Any],
               let contact = contactInfo.toContact() {
                onReceiveNewContactAddedNotification?(forUserID, contact)
            }
        default: break
        }
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
