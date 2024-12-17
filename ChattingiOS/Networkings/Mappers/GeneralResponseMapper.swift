//
//  GeneralResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

enum GeneralResponseMapper<R: Response, Model>: ResponseMapper where R.Model == Model {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> Model {
        try validate(response, with: data)
        
        guard let response = try? decoder.decode(R.self, from: data) else {
            throw .mapping
        }
        
        return response.toModel
    }
}

typealias ContactsResponseMapper = GeneralResponseMapper<ContactsResponse, [Contact]>
typealias ContactResponseMapper = GeneralResponseMapper<ContactResponse, Contact>
typealias TokenResponseMapper = GeneralResponseMapper<TokenResponse, Token>
typealias UserResponseMapper = GeneralResponseMapper<UserResponse, User>
typealias UserTokenResponseMapper = GeneralResponseMapper<UserTokenResponse, (user: User, token: Token)>
