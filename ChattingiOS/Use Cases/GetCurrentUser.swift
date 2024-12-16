//
//  GetCurrentUser.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

final class GetCurrentUser {
    private let client: HTTPClient
    private let getRequest: () -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping () -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func get() async throws(UseCaseError) -> User {
        do {
            let (data, response) = try await client.send(getRequest())
            return try UserResponseMapper.map(data, response: response)
        } catch {
            throw .map(error)
        }
    }
}
