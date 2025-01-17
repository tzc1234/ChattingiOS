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
        
        XCTAssertTrue(client.messages.isEmpty)
    }
    
    func test_perform_deliversRequestCreationErrorOnAnyRequestError() async throws {
        let (sut, _) = makeSUT(request: { _ in throw anyNSError() })
        
        try await assertThrowsError(_ = await sut.perform(with: "any")) { error in
            XCTAssertEqual(error as? UseCaseError, .requestCreation)
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
    
    private enum MapperStub: ResponseMapper {
        static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> String {
            ""
        }
    }
    
    @MainActor
    private final class HTTPClientSpy: HTTPClient {
        private(set) var messages = [Any]()
        
        func send(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
            fatalError()
        }
    }
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "error", code: 0)
}
