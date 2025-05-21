//
//  ImageDataMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/05/2025.
//

import Foundation

enum ImageDataMapper: ResponseMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> Data {
        try validate(response, with: data)
        return data
    }
}
