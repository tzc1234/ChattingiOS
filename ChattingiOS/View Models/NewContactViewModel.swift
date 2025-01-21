//
//  NewContactViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 01/01/2025.
//

import Foundation

final class NewContactViewModel: ObservableObject {
    @Published var emailInput = ""
    @Published private(set) var generalError: String?
    @Published private(set) var isLoading = false
    @Published private(set) var contact: Contact?
    
    var canSubmit: Bool { email.isValid }
    var email: Email { Email(emailInput) }
    
    private let newContact: NewContact
    
    init(newContact: NewContact) {
        self.newContact = newContact
    }
    
    @MainActor
    func addNewContact() {
        guard let email = email.value else { return }
        
        isLoading = true
        Task {
            do {
                contact = try await newContact.add(by: email)
            } catch let error as UseCaseError {
                self.generalError = error.toGeneralErrorMessage()
            }
            
            isLoading = false
        }
    }
}
