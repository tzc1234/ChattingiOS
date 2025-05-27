//
//  CacheImageData.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 22/05/2025.
//

import Foundation

actor CacheImageData {
    private let store: CoreDataMessagesStore
    
    init(store: CoreDataMessagesStore) {
        self.store = store
    }
    
    func cache(_ data: Data, for url: URL) async throws {
        try await store.saveImageData(data, for: url)
    }
}
