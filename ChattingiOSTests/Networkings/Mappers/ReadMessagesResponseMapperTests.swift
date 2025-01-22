//
//  ReadMessagesResponseMapperTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 22/01/2025.
//

import XCTest
@testable import ChattingiOS

final class ReadMessagesResponseMapperTests: XCTestCase {
    func test_map_deliversErrorOnNon200StatusCodeResponse() {
        let reason = "any reason"
        let data = Data("{\"reason\":\"\(reason)\"}".utf8)
        let non200StatusCodes = [199, 201, 300, 400]
        
        for code in non200StatusCodes {
            let response = HTTPURLResponse(statusCode: code)
            
            XCTAssertThrowsError(
                try ReadMessagesResponseMapper.map(data, response: response),
                "Expect statusCode: \(code) throws an error."
            ) { error in
                XCTAssertEqual(error as? MapperError, .server(reason: reason))
            }
        }
    }
}

private extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
