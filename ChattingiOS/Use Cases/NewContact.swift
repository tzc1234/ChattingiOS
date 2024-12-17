//
//  NewContact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

final class NewContact {
    private let client: HTTPClient
    private let getRequest: (String) -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping (String) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func add(by responderEmail: String) async throws(UseCaseError) -> Contact {
        let request = getRequest(responderEmail)
        do {
            let (data, response) = try await client.send(request)
            return try ContactResponseMapper.map(data, response: response)
        } catch {
            throw .map(error)
        }
    }
}
