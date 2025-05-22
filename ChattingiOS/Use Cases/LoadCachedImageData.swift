//
//  LoadCachedImageData.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 22/05/2025.
//

import Foundation

actor LoadCachedImageData {
    private let store: CoreDataMessagesStore
    
    init(store: CoreDataMessagesStore) {
        self.store = store
    }
    
    func load(for url: URL) async throws(UseCaseError) -> Data {
        guard let data = try? await store.retrieveImageData(for: url) else { throw .invalidData }
        
        return data
    }
}
