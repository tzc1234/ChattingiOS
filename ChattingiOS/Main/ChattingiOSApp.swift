//
//  ChattingiOSApp.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

@main
struct ChattingiOSApp: App {
    private let dependencies = DependenciesContainer()
    private let flow: Flow
    
    init() {
        flow = Flow(dependencies: dependencies)
        flow.observeUserSignIn()
    }
    
    var body: some Scene {
        WindowGroup {
            flow.startView()
        }
    }
}
