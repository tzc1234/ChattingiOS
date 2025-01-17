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
    func test_init_doesNotNotifyClientWhileCreation() async {
        let client = httpClientSpy()
        let sut = GeneralUseCase<String, MapperStub>(client: client) { _ in
            URLRequest(url: URL(string: "http://a-url.com")!)
        }
        
        XCTAssertTrue(client.messages.isEmpty)
        
        trackMemoryLeak(sut)
        trackMemoryLeak(client)
    }
    
    // MARK: - Helpers
    
    private enum MapperStub: ResponseMapper {
        typealias Model = String
        
        static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> String {
            ""
        }
    }
    
    @MainActor
    private final class httpClientSpy: HTTPClient {
        private(set) var messages = [Any]()
        
        func send(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
            fatalError()
        }
    }
}
