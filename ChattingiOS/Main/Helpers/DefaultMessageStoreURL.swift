//
//  DefaultMessageStoreURL.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 23/05/2025.
//

import CoreData

enum DefaultMessageStoreURL {
    static var url: URL {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.tszlung.ChattingiOS")!
            .appending(path: "messages-store.sqlite")
    }
}
