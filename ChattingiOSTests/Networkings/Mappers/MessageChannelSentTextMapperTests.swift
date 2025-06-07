//
//  MessageChannelSentTextMapperTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 22/01/2025.
//

import XCTest
@testable import ChattingiOS

final class MessageChannelSentTextMapperTests: XCTestCase {
    func test_map_deliversDataCorrectly() throws {
        let text = "any text"
        
        let data = try MessageChannelSentTextEncoder.encode(text)
        
        XCTAssertEqual(data, text.toData)
    }
}

private extension String {
    private struct TextSent: Encodable {
        let text: String
    }
    
    var toData: Data {
        try! JSONEncoder().encode(TextSent(text: self))
    }
}
