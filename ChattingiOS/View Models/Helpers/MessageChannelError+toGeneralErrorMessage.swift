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
            "Contact is belong to current user."
        case .disconnected:
            "Disconnected."
        case .userInitiateSignOut:
            nil
        case .requestCreation:
            "Request creation error."
        case .unknown, .unsupportedData,  .other:
            "Connection error."
        }
    }
}
