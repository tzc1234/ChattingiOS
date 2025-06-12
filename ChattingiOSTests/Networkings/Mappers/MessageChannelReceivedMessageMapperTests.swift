//
//  MessageChannelReceivedMessageMapperTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 22/01/2025.
//

import XCTest
@testable import ChattingiOS

final class MessageChannelReceivedMessageMapperTests: XCTestCase {
    func test_map_deliversInvalidDataErrorWithInvalidData() {
        let data = Data("invalid".utf8)
        
        XCTAssertThrowsError(_ = try MessageChannelReceivedMessageMapper.map(data)) { error in
            XCTAssertEqual(error as? MessageStreamError, .invalidData)
        }
    }
    
    func test_map_deliversMessageCorrectly() throws {
        let now = Date.now.removeTimeIntervalDecimal()
        let expectedMessages = [
            makeWebSocketMessage(
                Message(id: 1, text: "any text", senderID: 1, isRead: false, createdAt: now, editedAt: .distantFuture),
                previousID: nil
            ),
            makeWebSocketMessage(
                Message(id: 99, text: "another text", senderID: 99, isRead: true, createdAt: .distantFuture, editedAt: nil),
                previousID: 98
            )
        ]
        
        for expectedMessage in expectedMessages {
            let receivedMessage = try MessageChannelReceivedMessageMapper.map(expectedMessage.toData)
            
            XCTAssertEqual(receivedMessage, expectedMessage)
        }
    }
}
