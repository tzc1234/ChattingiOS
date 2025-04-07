//
//  NavigationControlView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/12/2024.
//

import SwiftUI

final class NavigationControlViewModel: ObservableObject {
    @Published var path = NavigationPath()
    @Published private(set) var contentID = UUID()
    
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
    @ObservedObject var viewModel: NavigationControlViewModel
    let content: () -> Content?
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            content()?.id(viewModel.contentID)
        }
    }
}
