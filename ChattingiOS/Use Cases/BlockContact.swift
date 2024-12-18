//
//  BlockContact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

protocol BlockContact {
    func block(for contactID: Int) async throws(UseCaseError) -> Contact
}

typealias DefaultBlockContact = GeneralUseCase<Int, ContactResponseMapper>

extension DefaultBlockContact: BlockContact {
    func block(for contactID: Int) async throws(UseCaseError) -> Contact {
        try await perform(with: contactID)
    }
}
