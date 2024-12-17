//
//  UnblockContact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

final class UnblockContact {
    private let client: HTTPClient
    private let getRequest: (Int) -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping (Int) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func unblock(with contactID: Int) async throws(UseCaseError) -> Contact {
        let request = getRequest(contactID)
        do {
            let (data, response) = try await client.send(request)
            return try ContactResponseMapper.map(data, response: response)
        } catch {
            throw .map(error)
        }
    }
}
