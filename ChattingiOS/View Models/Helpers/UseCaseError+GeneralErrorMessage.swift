//
//  UseCaseError+ErrorMessage.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 26/12/2024.
//

import Foundation

extension UseCaseError {
    func toGeneralErrorMessage() -> String? {
        switch self {
        case .server(let reason):
            reason
        case .invalidData:
            "Invalid data received."
        case .connectivity:
            "Connection error occurred, please try it later."
        case .requestCreationFailed:
            "Request creation error."
        case .userInitiateSignOut:
            nil
        case .saveCurrentUserFailed:
            "Cannot save current user data."
        }
    }
}
