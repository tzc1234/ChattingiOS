//
//  ReadMessagesResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

enum ReadMessagesResponseMapper: ResponseMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) {
        try validate(response, with: data)
    }
}
