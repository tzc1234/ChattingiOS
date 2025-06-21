//
//  SearchContactsResponse.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/06/2025.
//

import Foundation

struct SearchContactsResponse: Response {
    let contacts: [ContactResponse]
    let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case contacts
        case hasMore = "has_more"
    }
    
    var toModel: SearchedContacts {
        SearchedContacts(contacts: contacts.map(\.toModel), hasMore: hasMore)
    }
}
