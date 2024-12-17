//
//  ContactsResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum ContactsResponseMapper: ResponseMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> [Contact] {
        try validate(response, with: data)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let contactsResponse = try? decoder.decode(ContactsResponse.self, from: data) else {
            throw .mapping
        }
        
        return contactsResponse.toContacts
    }
}
