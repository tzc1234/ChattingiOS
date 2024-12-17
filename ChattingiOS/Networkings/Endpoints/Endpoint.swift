//
//  Endpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
}

protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var port: Int? { get }
    var path: String { get }
    var queryItems: [String: String]? { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var apiConstants: APIConstants { get }
}

extension Endpoint {
    var scheme: String { apiConstants.scheme }
    var host: String { apiConstants.host }
    var port: Int? { apiConstants.port }
    var apiPath: String { apiConstants.apiPath }
    var queryItems: [String: String]? { nil }
    var defaultHeaders: [String: String] {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
    var headers: [String: String]? { defaultHeaders }
    var body: Data? { nil }
    
    private var url: URL {
        assert(!scheme.isEmpty, "scheme should not be empty")
        assert(!host.isEmpty, "host should not be empty")
        assert(!path.isEmpty, "path should not be empty")
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = path
        components.queryItems = queryItems?.map { URLQueryItem(name: $0, value: $1) }
        return components.url!
    }
    
    var request: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}
