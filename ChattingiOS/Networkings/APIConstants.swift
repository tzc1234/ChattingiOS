//
//  APIConstants.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

protocol APIConstants {
    var scheme: String { get }
    var webSocketScheme: String { get }
    var host: String { get }
    var port: Int? { get }
    var apiPath: String { get }
}

struct DefaultAPIConstants: APIConstants {
    let scheme = "http"
    let webSocketScheme = "ws"
    let host = "localhost"
    let port: Int? = 8080
    let apiPath = "/api/v1/"
}
