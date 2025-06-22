//
//  ContactListViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/12/2024.
//

import Foundation

@MainActor @Observable
final class ContactListViewModel {
    private(set) var contacts = [Contact]()
    var generalError: String?
    var message: String?
    
    var isLoading: Bool { blockContactTask ?? unblockContactTask != nil }
    private var canLoadMore = true
    
    // Expose for testing.
    private(set) var loadMoreTask: Task<Void, Never>?
    private(set) var blockContactTask: Task<Void, Never>?
    private(set) var unblockContactTask: Task<Void, Never>?
    
    private let currentUserID: Int
    private let getContacts: GetContacts
    private let blockContact: BlockContact
    private let unblockContact: UnblockContact
    private let loadImageData: LoadImageData
    
    init(currentUserID: Int,
         getContacts: GetContacts,
         blockContact: BlockContact,
         unblockContact: UnblockContact,
         loadImageData: LoadImageData) {
        self.currentUserID = currentUserID
        self.getContacts = getContacts
        self.blockContact = blockContact
        self.unblockContact = unblockContact
        self.loadImageData = loadImageData
    }
    
    func loadContacts() async {
        do {
            let params = GetContactsParams(before: nil)
            contacts = try await getContacts.get(with: params)
            canLoadMore = !contacts.isEmpty
        } catch {
            generalError = error.toGeneralErrorMessage()
        }
    }
    
    func loadMoreContacts() {
        guard canLoadMore, loadMoreTask == nil else { return }
        
        loadMoreTask = Task {
            defer { loadMoreTask = nil }
            
            do throws(UseCaseError) {
                let lastUpdate = contacts.last?.lastUpdate
                let params = GetContactsParams(before: lastUpdate)
                let moreContacts = try await getContacts.get(with: params)
                canLoadMore = !moreContacts.isEmpty
                contacts += moreContacts
            } catch {
                generalError = error.toGeneralErrorMessage()
            }
        }
    }
    
    func addToTop(contact: Contact, message: String? = nil) {
        guard contacts.first(where: { $0.id == contact.id }) == nil else { return }
        
        contacts.insert(contact, at: 0)
        self.message = message
    }
    
    func replaceTo(newContact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == newContact.id }) {
            guard contacts[index].lastUpdate < newContact.lastUpdate else { return }
            
            contacts.remove(at: index)
            
            let toBeInsertedIndex = contacts.firstIndex { $0.lastUpdate < newContact.lastUpdate } ?? contacts.endIndex
            contacts.insert(newContact, at: toBeInsertedIndex)
        } else {
            addToTop(contact: newContact, message: "\(newContact.responder.name) added you.")
        }
    }
    
    func blockContact(contactID: Int) {
        guard let index = contacts.firstIndex(where: { $0.id == contactID }),
              contacts[index].blockedByUserID == nil,
              blockContactTask == nil else {
            return
        }
        
        blockContactTask = Task {
            defer { blockContactTask = nil }
            
            do throws(UseCaseError) {
                let blockedContact = try await blockContact.block(for: contactID)
                contacts[index] = blockedContact
            } catch {
                generalError = error.toGeneralErrorMessage()
            }
        }
    }
    
    func unblockContact(contactID: Int) {
        guard let index = contacts.firstIndex(where: { $0.id == contactID }),
              contacts[index].blockedByUserID != nil,
              unblockContactTask == nil else {
            return
        }
        
        unblockContactTask = Task {
            defer { unblockContactTask = nil }
            
            do throws(UseCaseError) {
                let unblockedContact = try await unblockContact.unblock(for: contactID)
                contacts[index] = unblockedContact
            } catch {
                generalError = error.toGeneralErrorMessage()
            }
        }
    }
    
    func canUnblock(blockedBy userID: Int) -> Bool {
        currentUserID == userID
    }
    
    func loadAvatarData(url: URL) async -> Data? {
        try? await loadImageData.load(for: url)
    }
}
