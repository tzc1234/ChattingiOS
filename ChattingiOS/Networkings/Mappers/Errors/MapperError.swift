//
//  MapperError.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum MapperError: Error {
    case server(reason: String)
    case mapping
}
