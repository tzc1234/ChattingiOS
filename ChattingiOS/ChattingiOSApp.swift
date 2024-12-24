//
//  ChattingiOSApp.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

final class DependenciesContainer {
    private let httpClient = URLSessionHTTPClient(session: .shared)
    private lazy var userSignIn = DefaultUserSign(client: httpClient) { try UserSignInEndpoint(params: $0).request }
    private lazy var signInViewModel = SignInViewModel { params throws(UseCaseError) in
        let user = try await self.userSignIn.signIn(with: params)
        print("user: \(user)")
    }
    private(set) lazy var flow = Flow(signInView: SignInView(viewModel: signInViewModel, signUpTapped: {}))
}


@main
struct ChattingiOSApp: App {
    private let dependenciesContainer = DependenciesContainer()
    
    var body: some Scene {
        WindowGroup {
            dependenciesContainer.flow.startView()
        }
    }
}
