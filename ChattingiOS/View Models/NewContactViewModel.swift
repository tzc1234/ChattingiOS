//
//  NewContactViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 01/01/2025.
//

import Foundation

final class NewContactViewModel: ObservableObject {
    @Published var email = ""
    @Published private(set) var error: String?
    @Published private(set) var isLoading = false
    @Published private(set) var contact: Contact?
    
    private let newContact: NewContact
    
    init(newContact: NewContact) {
        self.newContact = newContact
    }
    
    @MainActor
    func addNewContact() {
        guard isResponderEmailValid() else { return }
        
        isLoading = true
        Task {
            do {
                contact = try await newContact.add(by: email)
            } catch let error as UseCaseError {
                self.error = error.toGeneralErrorMessage()
            }
            
            isLoading = false
        }
    }
    
    private func isResponderEmailValid() -> Bool {
        guard email.isValidEmail else {
            error = .emailErrorMessage
            return false
        }
        
        error = nil
        return true
    }
}
