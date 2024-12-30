//
//  ContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct ContentView<SignedInContent: View, SignInContent: View, Sheet: View, CustomAlert: View>: View {
    @ObservedObject var viewModel: ContentViewModel
    let signedInContent: (User) -> SignedInContent
    let signInContent: () -> SignInContent
    let sheet: () -> Sheet
    let customAlert: () -> CustomAlert
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else {
                content
            }
        }
        .sheet(isPresented: $viewModel.showSheet, content: sheet)
        .alert("⚠️Oops!", isPresented: $viewModel.generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.generalError ?? "")
        }
        .customAlert(isPresenting: $viewModel.isPresentingCustomAlert, content: customAlert)
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
