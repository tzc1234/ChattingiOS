//
//  ContactListViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/12/2024.
//

import Foundation

final class ContactListViewModel: ObservableObject {
    @Published private(set) var contacts = [Contact]()
    @Published private(set) var isAddNewContactLoading = false
    @Published var generalError: String?
    
    private let getContacts: GetContacts
    private let newContact: NewContact
    
    init(getContacts: GetContacts, newContact: NewContact) {
        self.getContacts = getContacts
        self.newContact = newContact
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
    
    @MainActor
    func addNewContact(email: String) {
        isAddNewContactLoading = true
        
        Task {
            do {
                let contact = try await newContact.add(by: email)
                contacts.insert(contact, at: 0)
            } catch let error as UseCaseError {
                generalError = error.toGeneralErrorMessage()
            }
            
            isAddNewContactLoading = false
        }
    }
    
}
