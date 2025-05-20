//
//  GetContactsParams.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

struct GetContactsParams: Equatable {
    let before: Date?
    let limit: Int?
    
    init(before: Date?, limit: Int? = nil) {
        self.before = before
        self.limit = limit
    }
}
