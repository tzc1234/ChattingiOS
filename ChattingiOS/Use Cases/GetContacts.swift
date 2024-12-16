//
//  GetContacts.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

final class GetContacts {
    private let client: HTTPClient
    private let getRequest: (GetContactsParams) -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping (GetContactsParams) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func get(with params: GetContactsParams) async throws(UseCaseError) -> [Contact] {
        let request = getRequest(params)
        do {
            let (data, response) = try await client.send(request)
            return try ContactsResponseMapper.map(data, response: response)
        } catch {
            throw .map(error)
        }
    }
}
