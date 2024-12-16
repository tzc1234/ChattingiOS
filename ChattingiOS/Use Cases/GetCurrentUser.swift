//
//  GetCurrentUser.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

final class GetCurrentUser {
    private let client: HTTPClient
    private let getRequest: (String) -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping (String) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func get(with accessToken: String) async throws(UseCaseError) -> User {
        let request = getRequest(accessToken)
        do {
            let (data, response) = try await client.send(request)
            return try UserResponseMapper.map(data, response: response)
        } catch {
            throw .map(error)
        }
    }
}
