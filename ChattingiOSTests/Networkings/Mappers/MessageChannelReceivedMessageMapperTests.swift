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
}
