//
//  CaseIterable+next.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 12/12/2024.
//

extension CaseIterable where Self: Equatable {
    mutating func next() {
        let cases = Self.allCases
        let index = cases.firstIndex(of: self)!
        let nextIndex = cases.index(after: index)
        guard nextIndex < cases.endIndex else { return }
        
        self = cases[nextIndex]
    }
}
