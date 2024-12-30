//
//  NavigationControlView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/12/2024.
//

import SwiftUI

final class NavigationControlViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
    func show(_ next: some Hashable) {
        path.append(next)
    }
    
    func popTo(index: Int) {
        guard index <= path.count else { return }
        
        let destinationCount = path.count - index
        path.removeLast(destinationCount)
    }
    
    func popAll() {
        path.removeLast(path.count)
    }
}

struct NavigationControlView<Content: View>: View {
    @ObservedObject var viewModel: NavigationControlViewModel
    let content: () -> Content?
    
    var body: some View {
        NavigationStack(path: $viewModel.path, root: content)
    }
}
