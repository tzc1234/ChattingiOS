//
//  ContactResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

enum ContactResponseMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> Contact {
        guard response.isOK else {
            let reason = ErrorResponseMapper.map(errorData: data)
            throw .server(reason: reason ?? "Internal server error.")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let contactResponse = try? decoder.decode(ContactResponse.self, from: data) else {
            throw .mapping
        }
        
        return contactResponse.toContact
    }
}
