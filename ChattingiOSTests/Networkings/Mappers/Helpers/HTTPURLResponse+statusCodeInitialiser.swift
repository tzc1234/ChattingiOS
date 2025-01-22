//
//  HTTPURLResponse+statusCodeInitialiser.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 22/01/2025.
//

import Foundation

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
