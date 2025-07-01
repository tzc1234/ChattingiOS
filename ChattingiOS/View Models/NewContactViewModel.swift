//
//  NewContactViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 01/01/2025.
//

import Foundation

@MainActor @Observable
final class NewContactViewModel {
    var emailInput = ""
    private var generalError: String?
    private(set) var contact: Contact?
    
    var isLoading: Bool { task != nil }
    var canSubmit: Bool { email.isValid }
    var email: Email { Email(emailInput) }
    var error: String? { email.errorMessage ?? generalError }
    
    // Expose for testing.
    private(set) var task: Task<Void, Never>?
    
    private let newContact: NewContact
    
    init(newContact: NewContact) {
        self.newContact = newContact
    }
    
    func addNewContact() {
        guard let email = email.value, task == nil else { return }
        
        task = Task {
            defer { task = nil }
            
            do throws(UseCaseError) {
                contact = try await newContact.add(by: email)
            } catch {
                self.generalError = error.toGeneralErrorMessage()
            }
        }
    }
}
