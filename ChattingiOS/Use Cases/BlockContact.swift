//
//  BlockContact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

typealias BlockContact = GeneralUseCase<Int, ContactResponseMapper>

extension BlockContact {
    func block(with contactID: Params) async throws(UseCaseError) -> Mapper.Model {
        try await execute(with: contactID)
    }
}
