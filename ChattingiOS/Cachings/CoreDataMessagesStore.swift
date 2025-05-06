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
    
    func save(_ messages: [Message], with contactID: Int) async throws {
        guard !messages.isEmpty else { return }
        
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        try await context.perform {
            let contact = try ManagedContact.findOrCreate(by: contactID, in: context)
            let request = NSBatchInsertRequest(
                entityName: ManagedMessage.entityName,
                objects: messages.toObjects(contactID: contact.id)
            )
            try context.execute(request)
            contact.syncDate = .now
            try context.save()
        }
    }
    
    func retrieve(for messageID: MessageID?, contactID: Int, userID: Int, limit: Int) async throws -> [Message] {
        let context = container.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<ManagedMessage>(entityName: ManagedMessage.entityName)
            request.returnsObjectsAsFaults = false
            request.fetchLimit = limit
            
            let contactPredicate = NSPredicate(format: "contact.id = %d", contactID)
            switch messageID {
            case let .before(id):
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    contactPredicate,
                    NSPredicate(format: "id < %d", id)
                ])
                request.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedMessage.id, ascending: false)]
                
                let messages = try context.fetch(request).toMessages()
                return messages.sorted { $0.id < $1.id }
                
            case let .after(id):
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    contactPredicate,
                    NSPredicate(format: "id > %d", id)
                ])
                request.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedMessage.id, ascending: true)]
                
                return try context.fetch(request).toMessages()
                
            case .none:
                let firstUnreadMessageRequest = NSFetchRequest<ManagedMessage>(entityName: ManagedMessage.entityName)
                firstUnreadMessageRequest.returnsObjectsAsFaults = false
                firstUnreadMessageRequest.fetchLimit = 1
                firstUnreadMessageRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    contactPredicate,
                    NSPredicate(format: "isRead == %@", NSNumber(value: false)),
                    NSPredicate(format: "senderID != %d", userID),
                ])
                if let firstUnreadMessage = try context.fetch(firstUnreadMessageRequest).first {
                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                        contactPredicate,
                        NSPredicate(format: "id <= %d", firstUnreadMessage.id)
                    ])
                    request.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedMessage.id, ascending: false)]
                    
                    let messages = try context.fetch(request).toMessages()
                    return messages.sorted { $0.id < $1.id }
                }
                
                request.predicate = contactPredicate
                request.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedMessage.id, ascending: false)]
                let messages = try context.fetch(request).toMessages()
                return messages.sorted { $0.id < $1.id }
            }
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

private extension Message {
    func toObject(contactID: Int) -> [String: Any] {
        [
            "id": id,
            "text": text,
            "senderID": senderID,
            "isRead": isRead,
            "createdAt": createdAt,
            "contactID": contactID
        ]
    }
}

private extension [Message] {
    func toObjects(contactID: Int) -> [[String: Any]] {
        map { $0.toObject(contactID: contactID) }
    }
}
