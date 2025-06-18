//
//  CoreDataMessagesStore.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 05/05/2025.
//

import CoreData

actor CoreDataMessagesStore {
    let container: NSPersistentContainer
    
    init(url: URL) throws {
        guard let model = Self.model else { throw SetupError.modelNotFound }
        
        self.container = try Self.loadContainer(for: url, with: model)
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
        let description = NSPersistentStoreDescription(url: url)
        description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores { loadError = $1 }
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
