//
//  UserRegister.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

final class UserRegister {
    private let client: HTTPClient
    private let getRequest: (UserRegisterParams) -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping (UserRegisterParams) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func register(by params: UserRegisterParams) async throws(UseCaseError) -> (user: User, token: Token) {
        let request = getRequest(params)
        do {
            let (data, response) = try await client.send(request)
            return try UserTokenResponseMapper.map(data, response: response)
        } catch {
            throw .map(error)
        }
    }
}
