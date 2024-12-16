//
//  RefreshToken.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

final class RefreshToken {
    private let client: HTTPClient
    private let getRequest: (String) -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping (String) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func refresh(with token: String) async throws(UseCaseError) -> Token {
        let request = getRequest(token)
        do {
            let (data, response) = try await client.send(request)
            return try TokenResponseMapper.map(data, response: response)
        } catch {
            throw .map(error)
        }
    }
}
