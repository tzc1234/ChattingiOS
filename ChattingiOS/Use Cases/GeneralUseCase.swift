//
//  GeneralUseCase.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

final class GeneralUseCase<Params, Mapper: ResponseMapper> {
    private let client: HTTPClient
    private let getRequest: (Params) throws -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping (Params) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func perform(with params: Params) async throws(UseCaseError) -> Mapper.Model {
        let request: URLRequest
        do {
            request = try getRequest(params)
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
