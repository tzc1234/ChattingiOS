//
//  GetContactsParams.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

struct GetContactsParams {
    let before: Date?
    let limit: UInt?
    
    init(before: Date?, limit: UInt? = nil) {
        self.before = before
        self.limit = limit
    }
}
