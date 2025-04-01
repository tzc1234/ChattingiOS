//
//  AppDelegate.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 01/04/2025.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    var onReceivedReloadContactList: ((Int) -> Void)?
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let hexDeviceToken = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("device token: \(hexDeviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push notification registration error: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        if userInfo["action"] as? String == "new_contact_added", let userID = userInfo["user_id"] as? Int {
            onReceivedReloadContactList?(userID)
        }
        
        return .newData
    }
}
