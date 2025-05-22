//
//  LoadImageDataWithCacheDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 22/05/2025.
//

import Foundation

final class LoadImageDataWithCacheDecorator: LoadImageData {
    private let loadImageData: LoadImageData
    private let loadCachedImageData: LoadCachedImageData
    private let cacheImageData: CacheImageData
    
    init(loadImageData: LoadImageData, loadCachedImageData: LoadCachedImageData, cacheImageData: CacheImageData) {
        self.loadImageData = loadImageData
        self.loadCachedImageData = loadCachedImageData
        self.cacheImageData = cacheImageData
    }
    
    func load(for url: URL) async throws(UseCaseError) -> Data {
        if let cachedData = try? await loadCachedImageData.load(for: url) {
            return cachedData
        }
        
        let data = try await loadImageData.load(for: url)
        try? await cacheImageData.cache(data, for: url)
        return data
    }
}
