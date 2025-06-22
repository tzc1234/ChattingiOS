//
//  NavigationControlView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/12/2024.
//

import SwiftUI

@Observable
final class NavigationControlViewModel {
    var path = NavigationPath()
    private(set) var contentID = UUID()
    
    func show(next: some Hashable) {
        path.append(next)
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func forceReloadContent() {
        contentID = UUID()
    }
}

struct NavigationControlView<Content: View>: View {
    @Bindable var viewModel: NavigationControlViewModel
    let content: () -> Content
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            content()
                .id(viewModel.contentID)
        }
    }
}
