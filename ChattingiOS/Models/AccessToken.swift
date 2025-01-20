//
//  AccessToken.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

struct AccessToken {
    let wrappedString: String
    
    var bearerToken: String { "Bearer \(wrappedString)" }
}
