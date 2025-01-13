//
//  ChattingiOSApp.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

@main
struct ChattingiOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    
    private let dependencies = DependenciesContainer()
    private let flow: Flow
    
    init() {
        flow = Flow(dependencies: dependencies)
    }
    
    var body: some Scene {
        WindowGroup {
            flow.startView()
                .environmentObject(delegate)
        }
    }
}
