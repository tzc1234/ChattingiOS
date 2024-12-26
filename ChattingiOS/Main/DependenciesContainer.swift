//
//  DependenciesContainer.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 25/12/2024.
//

import Foundation

final class DependenciesContainer {
    private let httpClient = URLSessionHTTPClient(session: .shared)
    
    private(set) lazy var userSignIn: UserSignIn = DefaultUserSign(client: httpClient) {
        try UserSignInEndpoint(params: $0).request
    }
    private(set) lazy var userSignUp: UserSignUp = DefaultUserSignUp(client: httpClient) {
        UserSignUpEndpoint(params: $0).request
    }
}
