//
//  ChattingiOSApp.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

@main
struct ChattingiOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    private let dependencies = DependenciesContainer()
    private let flow: Flow
    
    init() {
        flow = Flow(dependencies: dependencies)
        appDelegate.onReceiveDeviceToken = { [weak flow] in flow?.deviceToken = $0 }
        
        let pushNotificationHandler = dependencies.pushNotificationHandler
        pushNotificationHandler.onReceiveNewContactAddedNotification = { [weak flow] userID, contact in
            flow?.addNewContactToList(for: userID, contact: contact)
        }
        
        Task { await pushNotificationHandler.setupPushNotifications() }
    }
    
    var body: some Scene {
        WindowGroup {
            flow.startView()
                .environmentObject(appDelegate)
        }
    }
}
