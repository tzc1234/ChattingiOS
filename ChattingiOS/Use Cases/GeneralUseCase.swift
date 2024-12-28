//
//  GeneralUseCase.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

actor GeneralUseCase<Params: Sendable, Mapper: ResponseMapper> {
    private let client: HTTPClient
    private let getRequest: @Sendable (Params) async throws -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping @Sendable (Params) async throws -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func perform(with params: Params) async throws(UseCaseError) -> Mapper.Model {
        let request: URLRequest
        do {
            request = try await getRequest(params)
        } catch {
            throw .requestConversion
        }
        
        do {
            let (data, response) = try await client.send(request)
            return try Mapper.map(data, response: response)
        } catch {
            throw .map(error)
        }
    }
}
