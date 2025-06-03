//
//  CTBackgroundView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct CTBackgroundView: View {
    @EnvironmentObject private var style: ViewStyleManager
    
    var body: some View {
        style.common.background
            .ignoresSafeArea()
    }
}
