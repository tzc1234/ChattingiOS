//
//  BlockContact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

typealias BlockContact = GeneralUseCase<Int, ContactResponseMapper>

extension BlockContact {
    func block(for contactID: Params) async throws(UseCaseError) -> Mapper.Model {
        try await perform(with: contactID)
    }
}
