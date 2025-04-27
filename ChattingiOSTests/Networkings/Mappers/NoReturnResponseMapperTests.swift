//
//  NoReturnResponseMapperTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 22/01/2025.
//

import XCTest
@testable import ChattingiOS

final class NoReturnResponseMapperTests: XCTestCase {
    func test_map_deliversErrorOnNon200StatusCodeResponse() {
        let reason = "Internal server error."
        let non200StatusCodes = [199, 201, 300, 400]
        
        for code in non200StatusCodes {
            let response = HTTPURLResponse(statusCode: code)
            
            XCTAssertThrowsError(
                try NoReturnResponseMapper.map(Data(), response: response),
                "Expect statusCode: \(code) throws an error."
            ) { error in
                XCTAssertEqual(error as? MapperError, .server(reason: reason, statusCode: code))
            }
        }
    }
    
    func test_map_deliversNoErrorOn200StatusCodeResponse() throws {
        let response = HTTPURLResponse(statusCode: 200)
        
        try NoReturnResponseMapper.map(Data(), response: response)
    }
    
    // MARK: - Helpers
    
    private enum NoReturnResponseMapper: ResponseMapper {}
}
