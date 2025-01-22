//
//  GeneralResponseMapperTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 22/01/2025.
//

import XCTest
@testable import ChattingiOS

final class GeneralResponseMapperTests: XCTestCase {
    func test_map_deliversErrorOnNon200StatusCodeResponses() {
        let reason = "any reason"
        let data = Data("{\"reason\":\"\(reason)\"}".utf8)
        let non200StatusCodes = [199, 201, 300, 400]
        
        for code in non200StatusCodes {
            let response = HTTPURLResponse(statusCode: code)
            
            XCTAssertThrowsError(
                _ = try Mapper.map(data, response: response),
                "Expect statusCode: \(code) throws an error."
            ) { error in
                XCTAssertEqual(error as? MapperError, .server(reason: reason))
            }
        }
    }
    
    func test_map_deliversMappingErrorOnInvalidData() {
        let data = Data("invalid".utf8)
        
        XCTAssertThrowsError(_ = try Mapper.map(data, response: statusCode200Response)) { error in
            XCTAssertEqual(error as? MapperError, .mapping)
        }
    }
    
    // MARK: - Helpers
    
    private typealias Mapper = GeneralResponseMapper<ResponseForTest>
    
    private var statusCode200Response: HTTPURLResponse {
        HTTPURLResponse(statusCode: 200)
    }
    
    private struct ResponseForTest: Response {
        let string: String
        var toModel: String { string }
    }
}
