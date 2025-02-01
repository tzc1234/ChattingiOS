//
//  NewContactViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 01/01/2025.
//

import Foundation

final class NewContactViewModel: ObservableObject {
    @Published var emailInput = ""
    @Published private var generalError: String?
    @Published private(set) var isLoading = false
    @Published private(set) var contact: Contact?
    
    var canSubmit: Bool { email.isValid }
    var email: Email { Email(emailInput) }
    var error: String? {
        email.errorMessage ?? generalError
    }
    
    private let newContact: NewContact
    
    init(newContact: NewContact) {
        self.newContact = newContact
    }
    
    @MainActor
    func addNewContact() {
        guard let email = email.value else { return }
        
        isLoading = true
        Task {
            do throws(UseCaseError) {
                contact = try await newContact.add(by: email)
            } catch {
                self.generalError = error.toGeneralErrorMessage()
            }
            
            isLoading = false
        }
    }
}
