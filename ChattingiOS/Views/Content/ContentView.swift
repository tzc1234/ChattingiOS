//
//  ContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct ContentView<SignedInContent: View, SignInContent: View, Sheet: View>: View {
    @Bindable var viewModel: ContentViewModel
    @ViewBuilder let signedInContent: (User) -> SignedInContent
    @ViewBuilder let signInContent: () -> SignInContent
    @ViewBuilder let sheet: () -> Sheet
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                CTLoadingView()
            } else {
                content
            }
        }
        .defaultAnimation(value: viewModel.isLoading)
        .defaultAnimation(value: viewModel.user != nil)
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
