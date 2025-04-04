//
//  UpdateDeviceToken.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 03/04/2025.
//

import Foundation

protocol UpdateDeviceToken: Sendable {
    func update(with params: UpdateDeviceTokenParams) async throws(UseCaseError)
}

typealias DefaultUpdateDeviceToken = GeneralUseCase<UpdateDeviceTokenParams, UpdateDeviceTokenResponseMapper>

extension DefaultUpdateDeviceToken: UpdateDeviceToken {
    func update(with params: UpdateDeviceTokenParams) async throws(UseCaseError) {
        try await perform(with: params)
    }
}
