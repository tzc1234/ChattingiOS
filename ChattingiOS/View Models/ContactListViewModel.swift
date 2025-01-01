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
    
    private let getContacts: GetContacts
    
    init(getContacts: GetContacts) {
        self.getContacts = getContacts
    }
    
    @MainActor
    func loadContacts() async {
        do {
            let params = GetContactsParams(before: nil)
            contacts = try await getContacts.get(with: params)
        } catch {
            generalError = error.toGeneralErrorMessage()
        }
    }
    
    func add(contact: Contact) {
        contacts.insert(contact, at: 0)
    }
}
