//
//  CoreDataMessagesStore.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 05/05/2025.
//

import CoreData

actor CoreDataMessagesStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(url: URL) throws {
        guard let model = Self.model else { throw SetupError.modelNotFound }
        
        self.container = try Self.loadContainer(for: url, with: model)
        self.context = container.newBackgroundContext()
    }
    
    deinit { Self.cleanup(container) }
}

extension CoreDataMessagesStore {
    enum SetupError: Error {
        case modelNotFound
        case loadContainerFailed
    }
    
    private static var modelName: String { "MessagesStore" }
    private static let model = getModel()
    
    private static func getModel() -> NSManagedObjectModel? {
        let currentBundle = Bundle(for: Self.self)
        guard let url = currentBundle.url(forResource: modelName, withExtension: "momd") else { return nil }
        
        return NSManagedObjectModel(contentsOf: url)
    }
    
    private static func loadContainer(for url: URL, with model: NSManagedObjectModel) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: url)]
        
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        guard loadError == nil else { throw SetupError.loadContainerFailed }
        
        return container
    }
    
    private static func cleanup(_ container: NSPersistentContainer) {
        let context = container.newBackgroundContext()
        context.performAndWait {
            let coordinator = container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
}
