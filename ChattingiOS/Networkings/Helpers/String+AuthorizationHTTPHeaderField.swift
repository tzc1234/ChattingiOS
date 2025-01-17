//
//  String+AuthorizationHTTPHeaderField.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/01/2025.
//

import Foundation

extension String {
    static var authorizationHTTPHeaderField: String { "Authorization" }
    
    var bearerToken: String { "Bearer " + self }
}
