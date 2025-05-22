//
//  ManagedImageData.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 22/05/2025.
//

import CoreData

@objc(ManagedImageData)
final class ManagedImageData: NSManagedObject {
    @NSManaged var url: URL
    @NSManaged var data: Data
}

extension ManagedImageData {
    static func find(for url: URL, in context: NSManagedObjectContext) throws -> ManagedImageData? {
        let request = NSFetchRequest<ManagedImageData>(entityName: String(describing: Self.self))
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "url == %@", url as CVarArg)
        return try context.fetch(request).first
    }
}
