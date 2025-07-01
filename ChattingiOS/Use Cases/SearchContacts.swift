//
//  SearchContacts.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/06/2025.
//

import Foundation

protocol SearchContacts: Sendable {
    func search(by params: SearchContactsParams) async throws(UseCaseError) -> SearchedContacts
}

typealias DefaultSearchContacts = GeneralUseCase<SearchContactsParams, SearchContactsResponseMapper>

extension DefaultSearchContacts: SearchContacts {
    func search(by params: SearchContactsParams) async throws(UseCaseError) -> SearchedContacts {
        try await perform(with: params)
    }
}
