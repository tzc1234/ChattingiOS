//
//  NavigationControlView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/12/2024.
//

import SwiftUI

final class NavigationControlViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
    func show(next: some Hashable) {
        path.append(next)
    }
}

struct NavigationControlView<Content: View>: View {
    @ObservedObject var viewModel: NavigationControlViewModel
    let content: () -> Content?
    
    var body: some View {
        NavigationStack(path: $viewModel.path, root: content)
    }
}
