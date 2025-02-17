//
//  URL+withoutQuery.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/02/2025.
//

import Foundation

extension URL {
    func withoutQuery() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.query = nil
        return components?.url
    }
}
