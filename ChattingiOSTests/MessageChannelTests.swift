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
    
    func test_getRequest_deliversUnknownErrorWhileReceivedOtherError() async {
        let expectedError = anyNSError()
        let (sut, _) = makeSUT(request: { _ in throw expectedError })
        
        await assertThrowsError(_ = try await sut.establish(for: contactID)) { error in
            assertMessageChannelError(error, as: .unknown)
        }
    }
    
    func test_getRequest_passesRequestToClientCorrectly() async {
        let expectedRequest = URLRequest(url: anyURL())
        var loggedContactIDs = [Int]()
        let (sut, client) = makeSUT(request: { contactID in
            loggedContactIDs.append(contactID)
            return expectedRequest
        })
        
        _ = try? await sut.establish(for: contactID)
        
        XCTAssertEqual(loggedContactIDs, [contactID])
        XCTAssertEqual(client.requests, [expectedRequest])
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
            XCTFail("Error is not a MessageChannelError.", file: file, line: line)
            return
        }
        
        switch (error, expectedError) {
        case (.invalidURL, .invalidURL),
            (.unauthorized, .unauthorized),
            (.notFound, .notFound),
            (.forbidden, .forbidden),
            (.unknown, .unknown),
            (.userInitiateSignOut, .userInitiateSignOut),
            (.requestCreationFailed, .requestCreationFailed):
            break
        case let (.other(receivedNSError as NSError), .other(expectedNSError as NSError)):
            XCTAssertEqual(receivedNSError, expectedNSError, file: file, line: line)
        default:
            XCTFail(
                "Error: \(error) is not as expected error: \(expectedError).",
                file: file,
                line: line
            )
        }
    }
    
    @MainActor
    private final class WebSocketClientSpy: WebSocketClient {
        private(set) var requests = [URLRequest]()
        
        func connect(_ request: URLRequest) async throws(WebSocketClientError) -> WebSocket {
            requests.append(request)
            throw .unknown
        }
    }
}
