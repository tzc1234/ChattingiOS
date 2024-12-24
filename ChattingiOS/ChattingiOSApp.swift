//
//  ChattingiOSApp.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

final class DependenciesContainer {
    private let httpClient = URLSessionHTTPClient(session: .shared)
    private(set) lazy var userSignIn: UserSignIn = DefaultUserSign(client: httpClient) {
        try UserSignInEndpoint(params: $0).request
    }
}

@main
struct ChattingiOSApp: App {
    private let dependencies = DependenciesContainer()
    private let flow: Flow
    
    init() {
        flow = Flow(dependencies: dependencies)
    }
    
    var body: some Scene {
        WindowGroup {
            flow.startView()
        }
    }
}
