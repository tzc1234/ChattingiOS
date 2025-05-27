//
//  LoadImageData.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/05/2025.
//

import Foundation

protocol LoadImageData: Sendable {
    func load(for url: URL) async throws(UseCaseError) -> Data
}

typealias DefaultLoadImageData = GeneralUseCase<URL, ImageDataMapper>

extension DefaultLoadImageData: LoadImageData {
    func load(for url: URL) async throws(UseCaseError) -> Data {
        try await perform(with: url)
    }
}
