//
//  TokenResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum TokenResponseMapper: ResponseMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> Token {
        try validate(response, with: data)
        
        guard let tokenResponse = try? decoder.decode(TokenResponse.self, from: data) else {
            throw MapperError.mapping
        }
        
        return tokenResponse.toModel
    }
}
