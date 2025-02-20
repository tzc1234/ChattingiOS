//
//  Response.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

protocol Response: Decodable {
    associatedtype Model
    
    var toModel: Model { get }
}
