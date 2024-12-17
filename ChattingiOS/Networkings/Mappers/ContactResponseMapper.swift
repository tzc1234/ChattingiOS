//
//  ContactResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

enum ContactResponseMapper: ResponseMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> Contact {
        try validate(response, with: data)
        
        guard let contactResponse = try? decoder.decode(ContactResponse.self, from: data) else {
            throw .mapping
        }
        
        return contactResponse.toContact
    }
}
