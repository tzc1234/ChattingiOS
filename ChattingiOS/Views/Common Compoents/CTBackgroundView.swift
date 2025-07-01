//
//  CTBackgroundView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct CTBackgroundView: View {
    @Environment(ViewStyleManager.self) private var style
    
    var body: some View {
        style.common.background
            .ignoresSafeArea()
    }
}
