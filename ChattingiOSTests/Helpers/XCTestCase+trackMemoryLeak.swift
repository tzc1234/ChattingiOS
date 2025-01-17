//
//  XCTestCase+trackMemoryLeak.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/01/2025.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeak(_ instance: Sendable & AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            if instance != nil {
                XCTFail(
                    "instance: \(String(describing: instance)) is not deallocated, potential memory leak.",
                    file: file,
                    line: line
                )
            }
        }
    }
}
