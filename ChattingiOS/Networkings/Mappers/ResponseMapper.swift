//
//  ResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

protocol ResponseMapper {
    associatedtype Model
    
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> Model
}

extension ResponseMapper {
    static func validate(_ response: HTTPURLResponse, with data: Data) throws(MapperError) {
        guard response.isOK else {
            let reason = ErrorResponseMapper.map(errorData: data)
            throw .server(reason: reason ?? defaultErrorReason, statusCode: response.statusCode)
        }
    }
    
    private static var defaultErrorReason: String { "Internal server error." }
}
