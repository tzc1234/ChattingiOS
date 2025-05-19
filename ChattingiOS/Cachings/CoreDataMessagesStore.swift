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
    
    func save(_ messages: [Message], for contactID: Int, userID: Int) async throws {
        guard !messages.isEmpty else { return }
        
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        try await context.perform {
            let contact = try ManagedContact.findOrNewInstance(id: contactID, userID: userID, in: context)
            let request = NSBatchInsertRequest(
                entityName: ManagedMessage.entityName,
                objects: messages.toObjects(contactID: contactID, userID: userID)
            )
            request.resultType = .objectIDs
            
            if let result = try context.execute(request) as? NSBatchInsertResult,
               let objectIDs = result.result as? [NSManagedObjectID] {
                for objectID in objectIDs {
                    let managedMessage = try context.existingObject(with: objectID) as? ManagedMessage
                    managedMessage?.contact = contact
                }
            }
            
            try context.save()
        }
    }
    
    func retrieve(for messageID: MessageID?, contactID: Int, userID: Int, limit: Int) async throws -> [Message] {
        let context = container.newBackgroundContext()
        return try await context.perform {
            switch messageID {
            case let .before(id):
                return try ManagedMessage
                    .find(before: id, in: context, contactID: contactID, userID: userID, limit: limit)
                    .toMessages()
            case .after: return []
            case .none:
                let managedMessages = try ManagedMessage
                    .findByFirstUnreadMessage(in: context, contactID: contactID, userID: userID, limit: limit)
                guard !managedMessages.isEmpty else {
                    return try ManagedMessage
                        .find(in: context, contactID: contactID, userID: userID, limit: limit)
                        .toMessages()
                }
                
                return managedMessages.toMessages()
            }
        }
    }
    
    func retrieve(by messageID: Int, userID: Int) async throws -> Message? {
        let context = container.newBackgroundContext()
        return try await context.perform {
            try ManagedMessage.find(by: messageID, userID: userID, in: context)?.toMessage()
        }
    }
    
    func updateMessageRead(until messageID: Int, contactID: Int, userID: Int) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            try ManagedMessage.read(until: messageID, contactID: contactID, userID: userID, in: context)
        }
    }
    
    func saveContacts(_ contacts: [Contact], for userID: Int) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            for contact in contacts {
                let managedContact = try ManagedContact.findOrNewInstance(id: contact.id, userID: userID, in: context)
                managedContact.responder = ManagedResponder.newInstance(by: contact.responder, in: context)
                managedContact.blockedByUserID = contact.blockedByUserID.map(NSNumber.init)
                managedContact.createdAt = contact.createdAt
            }
            try context.save()
        }
    }
    
    func retrieveContacts(by userID: Int, exceptIDs: [Int], before: Date?, limit: Int) async throws -> [Contact] {
        let context = container.newBackgroundContext()
        return try await context.perform {
            try ManagedContact.findAll(in: context, userID: userID, exceptIDs: exceptIDs, limit: limit)
                .toContacts(in: context)
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
    func toObject(contactID: Int, userID: Int) -> [String: Any] {
        [
            "id": id,
            "text": text,
            "senderID": senderID,
            "isRead": isRead,
            "createdAt": createdAt,
            "contactID": contactID,
            "userID": userID
        ]
    }
}

private extension [Message] {
    func toObjects(contactID: Int, userID: Int) -> [[String: Any]] {
        map { $0.toObject(contactID: contactID, userID: userID) }
    }
}
