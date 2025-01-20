//
//  GeneralUseCase.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

actor GeneralUseCase<Params: Sendable, Mapper: ResponseMapper> {
    private let client: HTTPClient
    private let getRequest: (Params) async throws -> URLRequest
    
    init(client: HTTPClient, getRequest: sending @escaping (Params) async throws -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func perform(with params: Params) async throws(UseCaseError) -> Mapper.Model {
        let request: URLRequest
        do {
            request = try await getRequest(params)
        } catch let error as UseCaseError {
            throw error
        } catch {
            throw .requestCreationFailed
        }
        
        do {
            let (data, response) = try await client.send(request)
            return try Mapper.map(data, response: response)
        } catch {
            throw .map(error)
        }
    }
}
