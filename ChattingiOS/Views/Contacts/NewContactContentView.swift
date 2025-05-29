//
//  NewContactView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 30/12/2024.
//

import SwiftUI

struct NewContactView: View {
    @ObservedObject var viewModel: NewContactViewModel
    @Binding var alertState: AlertState
    let onDisappear: (() -> Void)?
    
    var body: some View {
        _NewContactContentView(
            email: $viewModel.emailInput,
            error: viewModel.error,
            isLoading: viewModel.isLoading,
            canSubmit: viewModel.canSubmit,
            dismiss: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation { alertState.dismiss() }
                }
            },
            submitTapped: viewModel.addNewContact
        )
        .onDisappear(perform: onDisappear)
        .onChange(of: viewModel.contact) { contact in
            if contact != nil {
                // Fix animation when closing the custom alert.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation { alertState.dismiss() }
                }
            }
        }
    }
}

struct NewContactContentView: View {
    @Binding var email: String
    let error: String?
    let isLoading: Bool
    let canSubmit: Bool
    let submitTapped: () -> Void
    
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        CTCardView {
            VStack(spacing: 12) {
                VStack(spacing: 0) {
                    Image(systemName: "person.fill.badge.plus")
                        .font(.system(size: 70))
                        .foregroundStyle(.foreground)
                    
                    Text("Add New Contact")
                        .font(.headline)
                }
                .opacity(0.7)
                
                CTTextField(
                    placeholder: "Email",
                    text: $email,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress,
                    error: error
                )
                
                Button {
                    submitTapped()
                } label: {
                    LoadingTextLabel(isLoading: isLoading, title: "Submit")
                }
                .buttonStyle(.ctStyle(brightness: canSubmit ? 0 : -0.25))
                .disabled(!canSubmit)
            }
        }
        .disabled(isLoading)
    }
}

#Preview {
    NewContactContentView(
        email: .constant(""),
        error: nil,
        isLoading: false,
        canSubmit: false,
        submitTapped: {}
    )
}
