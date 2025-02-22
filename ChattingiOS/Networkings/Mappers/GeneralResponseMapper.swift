//
//  GeneralResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

enum GeneralResponseMapper<R: Response>: ResponseMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> R.Model {
        try validate(response, with: data)
        
        guard let response = try? decoder.decode(R.self, from: data) else {
            throw .mapping
        }
        
        return response.toModel
    }
    
    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

typealias MessagesResponseMapper = GeneralResponseMapper<MessagesResponse>
typealias ContactsResponseMapper = GeneralResponseMapper<ContactsResponse>
typealias ContactResponseMapper = GeneralResponseMapper<ContactResponse>
typealias TokenResponseMapper = GeneralResponseMapper<TokenResponse>
typealias UserTokenResponseMapper = GeneralResponseMapper<UserTokenResponse>
