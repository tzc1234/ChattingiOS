//
//  Date+TestHelpers.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 12/03/2025.
//

import Foundation

extension Date {
    func removeTimeIntervalDecimal() -> Date {
        Date(timeIntervalSince1970: TimeInterval(Int(timeIntervalSince1970)))
    }
}
