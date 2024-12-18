//
//  GetContacts.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

protocol GetContacts {
    func get(with params: GetContactsParams) async throws(UseCaseError) -> [Contact]
}

typealias DefaultGetContacts = GeneralUseCase<GetContactsParams, ContactsResponseMapper>

extension DefaultGetContacts: GetContacts {
    func get(with params: GetContactsParams) async throws(UseCaseError) -> [Contact] {
        try await perform(with: params)
    }
}
