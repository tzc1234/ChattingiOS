//
//  MessageChannelError+toGeneralErrorMessage.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/01/2025.
//

import Foundation

extension MessageChannelError {
    var toGeneralErrorMessage: String? {
        switch self {
        case .invalidURL:
            "Invalid URL."
        case .unauthorized:
            "Unauthorized user."
        case .notFound:
            "Contact not found."
        case .forbidden:
            "Contact is not belong to current user."
        case .userInitiateSignOut:
            nil
        case .requestCreation:
            "Cannot make a request."
        case .unknown,  .other:
            "Connection error."
        }
    }
}
