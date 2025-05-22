//
//  CoreDataMessagesStore+ImageData.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 22/05/2025.
//

import CoreData

extension CoreDataMessagesStore {
    func retrieveImageData(for url: URL) async throws -> Data? {
        let context = container.newBackgroundContext()
        return try await context.perform {
            try ManagedImageData.find(for: url, in: context)?.data
        }
    }
}
