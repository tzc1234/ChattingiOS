//
//  NewContact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

protocol NewContact {
    func add(by responderEmail: String) async throws(UseCaseError) -> Contact
}

typealias DefaultNewContact = GeneralUseCase<String, ContactResponseMapper>

extension DefaultNewContact: NewContact {
    func add(by responderEmail: String) async throws(UseCaseError) -> Contact {
        try await perform(with: responderEmail)
    }
}
