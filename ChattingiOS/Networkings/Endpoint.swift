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
}

protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var port: Int { get }
    var path: String { get }
    var queryItems: [String: String]? { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

extension Endpoint {
    var scheme: String { APIConstants.scheme }
    var host: String { APIConstants.host }
    var port: Int { APIConstants.port }
    var apiPath: String { APIConstants.apiPath }
    var queryItems: [String: String]? { nil }
    var httpMethod: HTTPMethod { .get }
    var defaultHeaders: [String: String] {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
    
    var url: URL {
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
