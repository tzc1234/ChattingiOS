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
    
    func test_getRequest_deliversMessageChannelErrorWhileReceivedMessageChannelError() async {
        let expectedError = MessageChannelError.invalidURL
        let (sut, _) = makeSUT(request: { _ in throw expectedError })
        
        await assertThrowsError(_ = try await sut.establish(for: contactID)) { error in
            assertMessageChannelError(error, as: expectedError)
        }
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
    
    private var contactID: Int { 99 }
    
    private func assertMessageChannelError(_ error: Error,
                                           as expectedError: MessageChannelError,
                                           file: StaticString = #filePath,
                                           line: UInt = #line) {
        guard let error = error as? MessageChannelError else {
            XCTFail("Error is not a MessageChannelError.")
            return
        }
        
        switch (error, expectedError) {
        case (.invalidURL, .invalidURL),
            (.unauthorized, .unauthorized),
            (.notFound, .notFound),
            (.forbidden, .forbidden),
            (.userInitiateSignOut, .userInitiateSignOut),
            (.requestCreationFailed, .requestCreationFailed):
            break
        case let (.other(receivedNSError as NSError), .other(expectedNSError as NSError)):
            XCTAssertEqual(receivedNSError, expectedNSError)
        default:
            XCTFail("Error: \(String(describing: error)) is not as expected error.")
        }
    }
    
    @MainActor
    private final class WebSocketClientSpy: WebSocketClient {
        private(set) var requests = [URLRequest]()
        
        func connect(_ request: URLRequest) async throws(WebSocketClientError) -> WebSocket {
            fatalError()
        }
    }
}
