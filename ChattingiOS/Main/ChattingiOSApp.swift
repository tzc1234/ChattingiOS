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
        appDelegate.onReceiveReadMessages = { [weak flow] userID, readMessages in
            flow?.update(readMessages, forUserID: userID)
        }
        
        Task { [handler = dependencies.pushNotificationHandler] in
            await handler.setupPushNotifications()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            flow.startView()
                .environment(appDelegate)
        }
    }
}
