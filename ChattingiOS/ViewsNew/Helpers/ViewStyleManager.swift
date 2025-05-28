//
//  ViewStyleManager.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

final class ViewStyleManager: ObservableObject {
    private let style = DefaultStyle()
    
    var common: DefaultStyle.Common { style.common }
    var textField: DefaultStyle.TextField { style.textField }
    var button: DefaultStyle.Button { style.button }
}
