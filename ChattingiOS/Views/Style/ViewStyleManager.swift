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
    var signUp: DefaultStyle.SignUp { style.signUp }
    var listRow: DefaultStyle.ListRow { style.listRow }
    var notice: DefaultStyle.Notice { style.notice }
    var popup: DefaultStyle.Popup { style.popup }
    var loadingView: DefaultStyle.LoadingView { style.loadingView }
    var message: DefaultStyle.Message { style.message}
    var profile: DefaultStyle.Profile { style.profile }
}
