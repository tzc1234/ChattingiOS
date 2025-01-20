//
//  XCTestCase+assertThrows.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/01/2025.
//

import XCTest

extension XCTestCase {
    @MainActor
    func assertThrowsError(_ expression: @autoclosure () async throws -> Void,
                           _ message: String = "",
                           file: StaticString = #filePath,
                           line: UInt = #line,
                           _ errorHandler: (Error) -> Void = { _ in }) async {
        do {
            try await expression()
            XCTFail(message, file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
