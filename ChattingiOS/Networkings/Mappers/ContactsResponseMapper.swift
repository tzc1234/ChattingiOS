//
//  ContactsResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum ContactsResponseMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> [Contact] {
        guard response.isOK else {
            let reason = ErrorResponseMapper.map(errorData: data)
            throw .server(reason: reason ?? "Internal server error.")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let contactsResponse = try? decoder.decode(ContactsResponse.self, from: data) else {
            throw .mapping
        }
        
        return contactsResponse.toContacts
    }
}
