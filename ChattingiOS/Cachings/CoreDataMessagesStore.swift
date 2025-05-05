//
//  CoreDataMessagesStore.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 05/05/2025.
//

import CoreData

actor CoreDataMessagesStore {
    enum MessageID {
        case before(Int)
        case after(Int)
    }
    
    private let container: NSPersistentContainer
    
    init(url: URL) throws {
        guard let model = Self.model else { throw SetupError.modelNotFound }
        
        self.container = try Self.loadContainer(for: url, with: model)
    }
    
    func save(_ messages: [Message]) async throws {
        guard !messages.isEmpty else { return }
        
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        try await context.perform {
            let request = NSBatchInsertRequest(entityName: ManagedMessage.entityName, objects: messages.toObjects())
            try context.execute(request)
            try context.save()
        }
    }
    
    func retrieve(for messageID: MessageID) async throws -> [Message] {
        let context = container.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<ManagedMessage>(entityName: ManagedMessage.entityName)
            request.returnsObjectsAsFaults = false
            request.predicate = switch messageID {
            case let .before(id): NSPredicate(format: "id < %@", id as CVarArg)
            case let .after(id): NSPredicate(format: "id > %@", id as CVarArg)
            }
            
            let managedMessages = try context.fetch(request)
            return managedMessages.toMessages()
        }
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

private extension Message {
    func toObject() -> [String: Any] {
        [
            "id": id,
            "text": text,
            "senderID": senderID,
            "isRead": isRead,
            "createdAt": createdAt
        ]
    }
}

private extension [Message] {
    func toObjects() -> [[String: Any]] {
        map { $0.toObject() }
    }
}
