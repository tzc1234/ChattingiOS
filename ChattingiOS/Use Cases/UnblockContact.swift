//
//  UnblockContact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

typealias UnblockContact = GeneralUseCase<Int, ContactResponseMapper>

extension UnblockContact {
    func unblock(with contactID: Params) async throws(UseCaseError) -> Mapper.Model {
        try await execute(with: contactID)
    }
}
