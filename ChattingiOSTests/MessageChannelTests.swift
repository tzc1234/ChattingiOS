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
    
    func test_establish_deliversMessageChannelErrorWhileReceivedWebsocketClientError() async {
        let errors: [(channelError: MessageChannelError, clientError: WebSocketClientError)] = [
            (.invalidURL, .invalidURL),
            (.unauthorized, .unauthorized),
            (.notFound, .notFound),
            (.forbidden, .forbidden),
            (.unknown, .unknown),
            (.other(anyNSError()), .other(anyNSError()))
        ]
        let (sut, _) = makeSUT(stubs: errors.map { .failure($0.clientError) })
        
        for error in errors {
            await assertThrowsError(_ = try await sut.establish(for: contactID)) { receivedError in
                assertMessageChannelError(receivedError, as: error.channelError)
            }
        }
    }
    
    func test_establish_deliversConnectionSuccessfully() async throws {
        _ = try await makeConnection()
    }
    
    // MARK: - MessageChannelConnection
    
    func test_sendText_deliversErrorOnWebSocketError() async throws {
        let (connection, _) = try await makeConnection(sendTextStub: .failure(anyNSError()))
        
        await assertThrowsError(try await connection.send(text: "any")) { error in
            XCTAssertEqual(error as NSError, anyNSError())
        }
    }
    
    func test_sendText_delegatesTextToWebSocketSuccessfully() async throws {
        let (connection, webSocket) = try await makeConnection()
        let text = "any text"
        
        try await connection.send(text: text)
        
        XCTAssertEqual(webSocket.loggedActions, [.sendText(text.toData())])
    }
    
    func test_close_deliversErrorOnWebSocketError() async throws {
        let (connection, _) = try await makeConnection(closeStub: .failure(anyNSError()))
        
        await assertThrowsError(try await connection.close()) { error in
            XCTAssertEqual(error as NSError, anyNSError())
        }
    }
    
    func test_close_delegatesCloseToWebSocketSuccessfully() async throws {
        let (connection, webSocket) = try await makeConnection()
        
        try await connection.close()
        
        XCTAssertEqual(webSocket.loggedActions, [.close])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(request: sending @escaping (Int) async throws -> URLRequest =
                         { _ in URLRequest(url: anyURL()) },
                         stubs: [Result<WebSocket, WebSocketClientError>] = [.failure(.unknown)],
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: MessageChannel, client: WebSocketClientSpy) {
        let client = WebSocketClientSpy(stubs: stubs)
        let sut = DefaultMessageChannel(client: client, getRequest: request)
        trackMemoryLeak(client, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func makeConnection(sendTextStub: Result<Void, Error> = .success(()),
                                closeStub: Result<Void, Error> = .success(()),
                                file: StaticString = #filePath,
                                line: UInt = #line) async throws -> (connection: MessageChannelConnection,
                                                                     webSocket: WebSocketSpy) {
        let spy = WebSocketSpy(sendTextStub: sendTextStub, closeStub: closeStub)
        let (sut, _) = makeSUT(stubs: [.success(spy)], file: file, line: line)
        let connection = try await sut.establish(for: contactID)
        return (connection, spy)
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
        
        private var stubs: [Result<WebSocket, WebSocketClientError>]
        
        init(stubs: [Result<WebSocket, WebSocketClientError>]) {
            self.stubs = stubs
        }
        
        func connect(_ request: URLRequest) async throws(WebSocketClientError) -> WebSocket {
            requests.append(request)
            return try stubs.removeFirst().get()
        }
    }
    
    @MainActor
    private final class WebSocketSpy: WebSocket {
        enum Action: Equatable {
            case sendText(Data)
            case close
        }
        
        private(set) var loggedActions = [Action]()
        
        private let sendTextStub: Result<Void, Error>
        private let closeStub: Result<Void, Error>
        
        init(sendTextStub: Result<Void, Error>, closeStub: Result<Void, Error>) {
            self.sendTextStub = sendTextStub
            self.closeStub = closeStub
        }
        
        func setObservers(dataObserver: DataObserver?, errorObserver: ErrorObserver?) async {
            
        }
        
        func send(data: Data) async throws {
            loggedActions.append(.sendText(data))
            try sendTextStub.get()
        }
        
        func close() async throws {
            loggedActions.append(.close)
            try closeStub.get()
        }
    }
}

private extension String {
    private struct TextSent: Encodable {
        let text: String
    }
    
    func toData() -> Data {
        try! JSONEncoder().encode(TextSent(text: self))
    }
}
