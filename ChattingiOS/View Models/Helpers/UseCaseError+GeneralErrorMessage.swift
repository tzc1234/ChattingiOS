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
        case let .server(reason, statusCode):
            // When status code is 401, it means that token refreshing is failed in Decorator.
            // The error should be already handled (go back to sign in), return nil to ignore it in Use Case scope.
            if statusCode == 401 { return nil }
            
            return reason
        case .invalidData:
            return "Invalid data received."
        case .connectivity:
            return "Connection error occurred, please try it later."
        case .requestCreationFailed:
            return "Request creation error."
        case .accessTokenNotFound:
            return nil
        case .saveCurrentUserFailed:
            return "Cannot save current user data."
        }
    }
}
