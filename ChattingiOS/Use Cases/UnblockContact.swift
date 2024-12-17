//
//  UnblockContact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

typealias UnblockContact = GeneralUseCase<Int, ContactResponseMapper>

extension UnblockContact {
    func unblock(for contactID: Params) async throws(UseCaseError) -> Mapper.Model {
        try await perform(with: contactID)
    }
}
