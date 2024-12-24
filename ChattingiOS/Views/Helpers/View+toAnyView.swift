//
//  View+anyView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/12/2024.
//

import SwiftUI

extension View {
    var toAnyView: AnyView {
        AnyView(self)
    }
}
