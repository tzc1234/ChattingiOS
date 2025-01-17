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
        
        _ = try? await sut.perform(with: expectedParam)
        
        XCTAssertEqual(paramsLogged, [expectedParam])
        XCTAssertEqual(client.requests, [expectedRequest])
    }
    
    func test_mapper_deliversInvalidDataErrorWhenReceivedMappingError() async {
        MapperStub.error = .mapping
        let (sut, _) = makeSUT()
        
        await assertThrowsError(_ = try await sut.perform(with: "any")) { error in
            XCTAssertEqual(error as? UseCaseError, .invalidData)
        }
    }
    
    func test_mapper_deliversServerErrorWhenReceivedMapperServerError() async {
        let reason = "any reason"
        MapperStub.error = .server(reason: reason)
        let (sut, _) = makeSUT()
        
        await assertThrowsError(_ = try await sut.perform(with: "any")) { error in
            XCTAssertEqual(error as? UseCaseError, .server(reason: reason))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = GeneralUseCase<String, MapperStub>
    
    private func makeSUT(request: sending @escaping (String) async throws -> URLRequest =
                         { _ in URLRequest(url: anyURL()) },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: SUT, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = SUT(client: client, getRequest: request)
        trackMemoryLeak(sut)
        trackMemoryLeak(client)
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
        
        static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> String {
            if let error { throw error }
            return ""
        }
    }
    
    @MainActor
    private final class HTTPClientSpy: HTTPClient {
        private(set) var requests = [URLRequest]()
        
        func send(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
            requests.append(request)
            return (Data(), HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
    }
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "error", code: 0)
}
