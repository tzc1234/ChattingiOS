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
        
        guard let contactsResponse = try? decoder.decode(ContactsResponse.self, from: data) else {
            throw .mapping
        }
        
        return contactsResponse.toModel
    }
}
