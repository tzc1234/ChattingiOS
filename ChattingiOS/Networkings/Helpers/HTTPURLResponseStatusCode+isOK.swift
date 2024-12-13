//
//  HTTPURLResponseStatusCode+isOK.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

extension HTTPURLResponse {
    var isOK: Bool {
        statusCode == okStatusCode
    }
    
    private var okStatusCode: Int { 200 }
}
