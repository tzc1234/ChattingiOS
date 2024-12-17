//
//  NewContact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

typealias NewContact = GeneralUseCase<String, ContactResponseMapper>

extension NewContact {
    func add(by responderEmail: Params) async throws(UseCaseError) -> Mapper.Model {
        try await perform(with: responderEmail)
    }
}
