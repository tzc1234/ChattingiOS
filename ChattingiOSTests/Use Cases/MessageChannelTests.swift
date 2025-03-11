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
        _ = try await establishConnection()
    }
    
    // MARK: - MessageChannelConnection
    
    func test_sendText_deliversErrorOnWebSocketError() async throws {
        let (connection, _) = try await establishConnection(sendTextStub: .failure(anyNSError()))
        
        await assertThrowsError(try await connection.send(text: "any")) { error in
            XCTAssertEqual(error as NSError, anyNSError())
        }
    }
    
    func test_sendText_delegatesTextToWebSocketSuccessfully() async throws {
        let (connection, webSocket) = try await establishConnection()
        let text = "any text"
        
        try await connection.send(text: text)
        
        XCTAssertEqual(webSocket.loggedActions, [.sendText(text.toData)])
    }
    
    func test_close_deliversErrorOnWebSocketError() async throws {
        let (connection, _) = try await establishConnection(closeStub: .failure(anyNSError()))
        
        await assertThrowsError(try await connection.close()) { error in
            XCTAssertEqual(error as NSError, anyNSError())
        }
    }
    
    func test_close_delegatesCloseToWebSocketSuccessfully() async throws {
        let (connection, webSocket) = try await establishConnection()
        
        try await connection.close()
        
        XCTAssertEqual(webSocket.loggedActions, [.close])
    }
    
    func test_messageStream_deliversUnsupportedDataErrorOnUnsupportedData() async throws {
        let (connection, _) = try await establishConnection(webSocketErrorStub: .unsupportedData)
        
        await assertThrowsError({ for try await _ in connection.messageStream {} }) { error in
            assertMessageChannelConnectionError(error, as: .unsupportedData)
        }
    }
    
    func test_messageStream_deliversOtherErrorOnOtherError() async throws {
        let (connection, _) = try await establishConnection(webSocketErrorStub: .other(anyNSError()))
        
        
        await assertThrowsError({ for try await _ in connection.messageStream {} }) { error in
            assertMessageChannelConnectionError(error, as: .other(anyNSError()))
        }
    }
    
    func test_messageStream_finishesOnDisconnectedError() async throws {
        let (connection, _) = try await establishConnection(webSocketErrorStub: .disconnected)
        
        await assertNoThrow({ for try await _ in connection.messageStream {} })
    }
    
    func test_messageStream_deliversUnsupportedDataOnReceivedWebSocketInvalidData() async throws {
        let invalidData = Data("invalid".utf8)
        let (connection, _) = try await establishConnection(messageDataStubs: [invalidData])
        let logger = MessagesLogger()
        
        await assertThrowsError({
            for try await message in connection.messageStream {
                logger.append(message)
            }
        }) { error in
            assertMessageChannelConnectionError(error, as: .unsupportedData)
        }
        XCTAssertTrue(logger.messages.isEmpty)
    }
    
    func test_messageStream_deliversMessagesSuccessfully() async throws {
        let nowInterval = Int(Date().timeIntervalSince1970)
        let now = Date(timeIntervalSince1970: TimeInterval(nowInterval))
        let messages = [
            Message(id: 0, text: "any text", senderID: 0, isRead: true, createdAt: .distantFuture),
            Message(id: 1, text: "another text", senderID: 1, isRead: true, createdAt: .distantPast),
            Message(id: 2, text: "another text 2", senderID: 0, isRead: false, createdAt: now),
        ]
        let (connection, _) = try await establishConnection(messageDataStubs: messages.map(\.toData))
        let logger = MessagesLogger()
        
        await assertNoThrow({
            for try await message in connection.messageStream {
                logger.append(message)
            }
        })
        XCTAssertEqual(logger.messages, messages)
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
    
    private func establishConnection(sendTextStub: Result<Void, Error> = .success(()),
                                     closeStub: Result<Void, Error> = .success(()),
                                     webSocketErrorStub: WebSocketError? = nil,
                                     messageDataStubs: [Data] = [],
                                     file: StaticString = #filePath,
                                     line: UInt = #line) async throws -> (connection: MessageChannelConnection,
                                                                          webSocket: WebSocketSpy) {
        let spy = WebSocketSpy(
            sendTextStub: sendTextStub,
            closeStub: closeStub,
            webSocketErrorStub: webSocketErrorStub,
            messageDataStubs: messageDataStubs
        )
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
            (.accessTokenNotFound, .accessTokenNotFound),
            (.requestCreationFailed, .requestCreationFailed):
            break
        case let (.other(receivedNSError as NSError), .other(expectedNSError as NSError)):
            XCTAssertEqual(receivedNSError, expectedNSError, file: file, line: line)
        default:
            XCTFail("Error: \(error) is not as expected error: \(expectedError).", file: file, line: line)
        }
    }
    
    private func assertMessageChannelConnectionError(_ error: Error,
                                                     as expectedError: MessageChannelConnectionError,
                                                     file: StaticString = #filePath,
                                                     line: UInt = #line) {
        guard let error = error as? MessageChannelConnectionError else {
            return XCTFail("Error is not a MessageChannelConnectionError", file: file, line: line)
        }
        
        switch (error, expectedError) {
        case (.unsupportedData, .unsupportedData):
            break
        case let (.other(receivedNSError as NSError), .other(expectedNSError as NSError)):
            XCTAssertEqual(receivedNSError, expectedNSError, file: file, line: line)
        default:
            XCTFail("Error: \(error) is not as expected error: \(expectedError).", file: file, line: line)
        }
    }
    
    @MainActor
    private final class WebSocketClientSpy: WebSocketClient {
        typealias Stub = Result<WebSocket, WebSocketClientError>
        
        private(set) var requests = [URLRequest]()
        
        private var stubs: [Stub]
        
        init(stubs: [Stub]) {
            self.stubs = stubs
        }
        
        func connect(_ request: URLRequest) async throws(WebSocketClientError) -> WebSocket {
            requests.append(request)
            return try stubs.removeFirst().get()
        }
    }
    
    @MainActor
    private final class MessagesLogger {
        private(set) var messages = [Message]()
        
        func append(_ message: Message) {
            messages.append(message)
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
        private let webSocketErrorStub: WebSocketError?
        private var messageDataStubs: [Data]
        
        nonisolated let outputStream: AsyncThrowingStream<Data, Error>
        private let continuation: AsyncThrowingStream<Data, Error>.Continuation
        
        init(sendTextStub: Result<Void, Error>,
             closeStub: Result<Void, Error>,
             webSocketErrorStub: WebSocketError?,
             messageDataStubs: [Data]) {
            self.sendTextStub = sendTextStub
            self.closeStub = closeStub
            self.webSocketErrorStub = webSocketErrorStub
            self.messageDataStubs = messageDataStubs
            (self.outputStream, self.continuation) = AsyncThrowingStream.makeStream()
        }
        
        func start() async {
            if !messageDataStubs.isEmpty {
                messageDataStubs.forEach { continuation.yield($0) }
                continuation.finish(throwing: WebSocketError.disconnected)
            }
            
            if let webSocketErrorStub {
                continuation.finish(throwing: webSocketErrorStub)
            }
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
    
    var toData: Data {
        try! JSONEncoder().encode(TextSent(text: self))
    }
}

private extension Message {
    private struct MessageResponse: Encodable {
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
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try! encoder.encode(MessageResponse(self))
    }
}
