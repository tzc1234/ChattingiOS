//
//  GetContacts.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

typealias GetContacts = GeneralUseCase<GetContactsParams, ContactsResponseMapper>

extension GetContacts {
    func get(with params: Params) async throws(UseCaseError) -> Mapper.Model {
        try await execute(with: params)
    }
}
