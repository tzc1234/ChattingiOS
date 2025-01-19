//
//  MessageChannelTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 19/01/2025.
//

import XCTest
@testable import ChattingiOS

@MainActor
final class MessageChannelTests: XCTestCase {
    func test_init_doesNotNotifyClientUponCreation() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(request: sending @escaping (Int) async throws -> URLRequest =
                         { _ in URLRequest(url: anyURL()) },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: MessageChannel, client: WebSocketClientSpy) {
        let client = WebSocketClientSpy()
        let sut = DefaultMessageChannel(client: client, getRequest: request)
        trackMemoryLeak(client, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, client)
    }
    
    @MainActor
    private final class WebSocketClientSpy: WebSocketClient {
        private(set) var requests = [URLRequest]()
        
        func connect(_ request: URLRequest) async throws(WebSocketClientError) -> WebSocket {
            fatalError()
        }
    }
}
