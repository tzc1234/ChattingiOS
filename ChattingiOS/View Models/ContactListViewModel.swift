//
//  ContactListViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/12/2024.
//

import Foundation

@MainActor
final class ContactListViewModel: ObservableObject {
    @Published private(set) var contacts = [Contact]()
    @Published var generalError: String?
    @Published var message: String?
    @Published private(set) var isLoading = false
    
    private var canLoadMore = true
    
    private let currentUserID: Int
    private let getContacts: GetContacts
    private let blockContact: BlockContact
    private let unblockContact: UnblockContact
    
    init(currentUserID: Int, getContacts: GetContacts, blockContact: BlockContact, unblockContact: UnblockContact) {
        self.currentUserID = currentUserID
        self.getContacts = getContacts
        self.blockContact = blockContact
        self.unblockContact = unblockContact
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
        guard canLoadMore else { return }
        
        Task {
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
    
    func addToTop(contact: Contact, message: String) {
        guard contacts.first(where: { $0.id == contact.id }) == nil else { return }
        
        contacts.insert(contact, at: 0)
        self.message = message
    }
    
    func replaceTo(newContact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == newContact.id }) {
            guard contacts[index].lastUpdate < newContact.lastUpdate else { return }
            
            contacts[index] = newContact
        } else {
            addToTop(contact: newContact, message: "New contact added.")
        }
    }
    
    func blockContact(contactID: Int) {
        guard let index = contacts.firstIndex(where: { $0.id == contactID }),
              contacts[index].blockedByUserID == nil else {
            return
        }
        
        isLoading = true
        Task {
            do throws(UseCaseError) {
                let blockedContact = try await blockContact.block(for: contactID)
                contacts[index] = blockedContact
            } catch {
                generalError = error.toGeneralErrorMessage()
            }
            
            isLoading = false
        }
    }
    
    func unblockContact(contactID: Int) {
        guard let index = contacts.firstIndex(where: { $0.id == contactID }),
                contacts[index].blockedByUserID != nil else {
            return
        }
        
        isLoading = true
        Task {
            do throws(UseCaseError) {
                let unblockedContact = try await unblockContact.unblock(for: contactID)
                contacts[index] = unblockedContact
            } catch {
                generalError = error.toGeneralErrorMessage()
            }
            
            isLoading = false
        }
    }
    
    func canUnblock(blockedBy userID: Int) -> Bool {
        currentUserID == userID
    }
}
