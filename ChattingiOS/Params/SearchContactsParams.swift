//
//  SearchContactsParams.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/06/2025.
//

import Foundation

struct SearchContactsParams {
    let searchTerm: String
    let before: Date?
    let limit: Int?
    
    init(searchTerm: String, before: Date? = nil, limit: Int? = nil) {
        self.searchTerm = searchTerm
        self.before = before
        self.limit = limit
    }
}
