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
        let expectedMessages = [
            Message(id: 1, text: "any text", senderID: 1, isRead: false, createdAt: nil),
            Message(id: 99, text: "another text", senderID: 99, isRead: true, createdAt: .distantFuture)
        ]
        
        for expectedMessage in expectedMessages {
            let receivedMessage = try MessageChannelReceivedMessageMapper.map(expectedMessage.toData)
            
            XCTAssertEqual(receivedMessage, expectedMessage)
        }
    }
}

private extension Message {
    private struct MessageResponseForTest: Encodable {
        let id: Int
        let text: String
        let sender_id: Int
        let is_read: Bool
        let created_at: Date?
        
        init(_ message: Message) {
            self.id = message.id
            self.text = message.text
            self.sender_id = message.senderID
            self.is_read = message.isRead
            self.created_at = message.createdAt
        }
    }
    
    var toData: Data {
        let response = MessageResponseForTest(self)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try! encoder.encode(response)
    }
}
