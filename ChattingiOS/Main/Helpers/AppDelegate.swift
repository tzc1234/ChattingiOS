//
//  AppDelegate.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 01/04/2025.
//

import UIKit
@preconcurrency import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    var onReceivedNewContactAdded: ((Int, Contact) -> Void)?
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Task { await setupPushNotifications() }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let hexDeviceToken = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("device token: \(hexDeviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push notification registration error: \(error)")
    }
}

extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {
    private func setupPushNotifications() async {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let authorizationStatus = await center.notificationSettings().authorizationStatus
        switch authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert])
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
        print("didReceive userInfo: \(userInfo)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        let action = userInfo["action"] as? String
        switch action {
        case "new_contact_added":
            if let forUserID = userInfo["for_user_id"] as? Int,
               let contactInfo = userInfo["contact"] as? [AnyHashable: Any],
               let contact = contactInfo.toModel() {
                onReceivedNewContactAdded?(forUserID, contact)
            }
        default:
            break
        }
        
        return .init(rawValue: 0)
    }
}

private extension [AnyHashable: Any] {
    func toModel() -> Contact? {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let contactResponse = try? decoder.decode(ContactResponse.self, from: data)
        return contactResponse?.toModel
    }
}
