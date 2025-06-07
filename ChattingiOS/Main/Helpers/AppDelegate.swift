//
//  AppDelegate.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 01/04/2025.
//

import UIKit
@preconcurrency import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    var onReceiveDeviceToken: ((String) -> Void)?
    var onReceiveUpdateReadMessages: ((UserID, ReadMessages) -> Void)?
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let hexDeviceToken = deviceToken.map { String(format: "%02x", $0) }.joined()
        onReceiveDeviceToken?(hexDeviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push notification registration error: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let action = userInfo["action"] as? String, action == "read_messages",
              let forUserID = userInfo["for_user_id"] as? UserID,
              let contactID = userInfo["contact_id"] as? Int,
              let untilMessageID = userInfo["until_message_id"] as? Int,
              let timestampString = userInfo["timestamp"] as? String,
              let timestamp = ISO8601DateFormatter().date(from: timestampString) else {
            return completionHandler(.noData)
        }
        
        onReceiveUpdateReadMessages?(forUserID, ReadMessages(
            contactID: contactID,
            untilMessageID: untilMessageID,
            timestamp: timestamp
        ))
        completionHandler(.newData)
    }
}
