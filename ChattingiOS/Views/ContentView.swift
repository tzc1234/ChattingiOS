//
//  ContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct ContentView<SignedInContent: View, SignInContent: View, Sheet: View>: View {
    @ObservedObject var viewModel: ContentViewModel
    let signedInContent: (User) -> SignedInContent
    let signInContent: () -> SignInContent
    let sheet: () -> Sheet
    
    var body: some View {
        ZStack {
            CTLoadingView()
                .opacity(viewModel.isLoading ? 1 : 0)
            
            content
                .opacity(viewModel.isLoading ? 0 : 1)
        }
        .defaultAnimation(duration: 0.3, value: viewModel.isLoading)
        .sheet(isPresented: $viewModel.showSheet, content: sheet)
        .alert("⚠️Oops!", isPresented: $viewModel.generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.generalError ?? "")
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if let user = viewModel.user {
            signedInContent(user)
        } else {
            signInContent()
        }
    }
}
