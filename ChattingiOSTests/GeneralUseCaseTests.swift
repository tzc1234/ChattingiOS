//
//  GeneralUseCaseTests.swift
//  GeneralUseCaseTests
//
//  Created by Tsz-Lung on 17/01/2025.
//

import XCTest
@testable import ChattingiOS

@MainActor
final class GeneralUseCaseTests: XCTestCase {
    func test_init_doesNotNotifyClientWhileCreation() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_request_deliversRequestCreationErrorOnAnyRequestError() async {
        let (sut, _) = makeSUT(request: { _ in throw anyNSError() })
        
        await assertThrowsError(_ = try await sut.perform(with: "any")) { error in
            XCTAssertEqual(error as? UseCaseError, .requestCreation)
        }
    }
    
    func test_request_deliversOtherUseCaseErrorOnRequestWithOtherUseCaseError() async {
        let useCaseError = UseCaseError.connectivity
        let (sut, _) = makeSUT(request: { _ in throw useCaseError })
        
        await assertThrowsError(_ = try await sut.perform(with: "any")) { error in
            XCTAssertEqual(error as? UseCaseError, useCaseError)
        }
    }
    
    func test_request_getsRequestCorrectly() async throws {
        let expectedRequest = requestForTest()
        let expectedParam = "any"
        var paramsLogged = [String]()
        let (sut, client) = makeSUT(request: {
            paramsLogged.append($0)
            return expectedRequest
        })
        
        _ = try await sut.perform(with: expectedParam)
        
        XCTAssertEqual(paramsLogged, [expectedParam])
        XCTAssertEqual(client.requests, [expectedRequest])
    }
    
    func test_mapper_deliversInvalidDataErrorWhenReceivedMappingError() async {
        let (sut, _) = makeSUT()
        MapperStub.error = .mapping
        
        await assertThrowsError(_ = try await sut.perform(with: "any")) { error in
            XCTAssertEqual(error as? UseCaseError, .invalidData)
        }
    }
    
    func test_mapper_deliversServerErrorWhenReceivedMapperServerError() async {
        let reason = "any reason"
        let (sut, _) = makeSUT()
        MapperStub.error = .server(reason: reason)
        
        await assertThrowsError(_ = try await sut.perform(with: "any")) { error in
            XCTAssertEqual(error as? UseCaseError, .server(reason: reason))
        }
    }
    
    func test_perform_deliversConnectivityErrorOnClientError() async {
        let (sut, _) = makeSUT(stub: .failure(anyNSError()))
        
        await assertThrowsError(_ = try await sut.perform(with: "any")) { error in
            XCTAssertEqual(error as? UseCaseError, .connectivity)
        }
    }
    
    func test_perform_deliversModelCorrectly() async throws {
        let expectedData = Data("any data".utf8)
        let expectedResponse = anyHTTPURLResponse()
        let (sut, _) = makeSUT(stub: .success((expectedData, expectedResponse)))
        
        let model = try await sut.perform(with: "any")
        
        XCTAssertEqual(model.data, expectedData)
        XCTAssertEqual(model.response, expectedResponse)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = GeneralUseCase<String, MapperStub>
    
    private func makeSUT(request: sending @escaping (String) async throws -> URLRequest =
                         { _ in URLRequest(url: anyURL()) },
                         stub: Result<(Data, HTTPURLResponse), Error> = .success((Data(), anyHTTPURLResponse())),
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: SUT, client: HTTPClientSpy) {
        MapperStub.error = nil
        let client = HTTPClientSpy(stub: stub)
        let sut = SUT(client: client, getRequest: request)
        trackMemoryLeak(sut, file: file, line: line)
        trackMemoryLeak(client, file: file, line: line)
        return (sut, client)
    }
    
    private func requestForTest() -> URLRequest {
        var request = URLRequest(url: URL(string: "http://a-url.com")!)
        request.httpMethod = "POST"
        request.setValue("token", forHTTPHeaderField: .authorizationHTTPHeaderField)
        return request
    }
    
    private enum MapperStub: ResponseMapper {
        nonisolated(unsafe) static var error: MapperError?
        
        static func map(_ data: Data,
                        response: HTTPURLResponse) throws(MapperError) -> (data: Data, response: HTTPURLResponse) {
            if let error { throw error }
            return (data, response)
        }
    }
    
    @MainActor
    private final class HTTPClientSpy: HTTPClient {
        private(set) var requests = [URLRequest]()
        private var stub: Result<(Data, HTTPURLResponse), Error>
        
        init(stub: Result<(Data, HTTPURLResponse), Error>) {
            self.stub = stub
        }
        
        func send(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
            requests.append(request)
            return try stub.get()
        }
    }
}
