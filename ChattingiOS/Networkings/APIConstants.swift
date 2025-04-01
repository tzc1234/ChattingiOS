//
//  APIConstants.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

struct APIConstants {
    let scheme: String
    let webSocketScheme: String
    let host: String
    let port: Int?
    let apiPath: String
    
    init(scheme: String = "http",
         webSocketScheme: String = "ws",
         host: String = "localhost", // Change to your server's hostname here.
         port: Int? = 8080,
         apiPath: String = "/api/v1/") {
        self.scheme = scheme
        self.webSocketScheme = webSocketScheme
        self.host = host
        self.port = port
        self.apiPath = apiPath
    }
}
