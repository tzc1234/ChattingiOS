//
//  BindingString+toBool.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 26/12/2024.
//

import SwiftUI

extension Binding<String?> {
    var toBool: Binding<Bool> {
        Binding<Bool> {
            wrappedValue != nil
        } set: { value in
            if !value {
                wrappedValue = nil
            }
        }
    }
}
