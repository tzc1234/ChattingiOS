//
//  ContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct ContentView<SignedInContent: View, SignInContent: View>: View {
    @ObservedObject var viewModel: ContentViewModel
    let signedInContent: () -> SignedInContent
    let signInContent: () -> SignInContent
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else {
                content
            }
        }
        .alert("⚠️Oops!", isPresented: $viewModel.generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.generalError ?? "")
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isSignedIn {
            signedInContent()
        } else {
            signInContent()
        }
    }
}
