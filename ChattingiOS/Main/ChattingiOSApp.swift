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
        appDelegate.onReceivedReloadContactList = flow.shouldReloadContactList
    }
    
    var body: some Scene {
        WindowGroup {
            flow.startView()
                .environmentObject(appDelegate)
        }
    }
}
