//
//  ContactListViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/12/2024.
//

import Foundation

final class ContactListViewModel: ObservableObject {
    @Published private(set) var contacts = [Contact]()
    @Published var generalError: String?
    private var canLoadMore = true
    
    private let getContacts: GetContacts
    
    init(getContacts: GetContacts) {
        self.getContacts = getContacts
    }
    
    @MainActor
    func loadContacts() async {
        do {
            let params = GetContactsParams(before: nil)
            contacts = try await getContacts.get(with: params)
            canLoadMore = !contacts.isEmpty
        } catch {
            generalError = error.toGeneralErrorMessage()
        }
    }
    
    @MainActor
    func loadMoreContacts() {
        guard canLoadMore else { return }
        
        Task {
            do {
                let lastUpdate = contacts.last?.lastUpdate
                let params = GetContactsParams(before: lastUpdate)
                let moreContacts = try await getContacts.get(with: params)
                canLoadMore = !moreContacts.isEmpty
                contacts += moreContacts
            } catch let error as UseCaseError {
                generalError = error.toGeneralErrorMessage()
            }
        }
    }
    
    func add(contact: Contact) {
        contacts.insert(contact, at: 0)
    }
}
