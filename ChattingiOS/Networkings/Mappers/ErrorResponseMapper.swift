//
//  ErrorResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

enum ErrorResponseMapper {
    private struct ErrorResponse: Decodable {
        let reason: String
    }
    
    static func map(errorData: Data) -> String? {
        guard let response = try? JSONDecoder().decode(ErrorResponse.self, from: errorData) else {
            return nil
        }
        
        return response.reason
    }
}
