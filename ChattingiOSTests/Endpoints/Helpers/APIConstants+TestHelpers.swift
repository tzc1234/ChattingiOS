//
//  APIConstants+TestHelpers.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 15/02/2025.
//

import Foundation
@testable import ChattingiOS

extension APIConstants {
    static var test: Self {
        APIConstants(
            scheme: "http",
            webSocketScheme: "ws",
            host: "test-host",
            port: 81,
            apiPath: "/api-path/"
        )
    }
    
    func url(last: String) -> URL {
        let string = "\(scheme)://\(host):\(port!)\(apiPath)\(last)"
        return URL(string: string)!
    }
}
