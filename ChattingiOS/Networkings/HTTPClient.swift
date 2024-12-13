//
//  HTTPClient.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

protocol HTTPClient {
    func run(endpoint: Endpoint) async throws -> (data: Data, response: HTTPURLResponse)
}

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    enum Error: Swift.Error {
        case unexpectedResponseRepresentationError
    }
    
    func run(endpoint: Endpoint) async throws -> (data: Data, response: HTTPURLResponse) {
        let (data, response) = try await session.data(for: endpoint.request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.unexpectedResponseRepresentationError
        }
        
        return (data, httpResponse)
    }
}
