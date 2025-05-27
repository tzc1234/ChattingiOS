//
//  CoreDataMessagesStore+ImageData.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 22/05/2025.
//

import CoreData

extension CoreDataMessagesStore {
    func saveImageData(_ data: Data, for url: URL) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let managedImageData = try ManagedImageData.findOrNewInstance(for: url, in: context)
            managedImageData.data = data
            try context.save()
        }
    }
    
    func retrieveImageData(for url: URL) async throws -> Data? {
        let context = container.newBackgroundContext()
        return try await context.perform {
            try ManagedImageData.find(for: url, in: context)?.data
        }
    }
}
