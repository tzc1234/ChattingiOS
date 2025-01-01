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
    
    var body: some View {
        NewContactContentView(
            email: $viewModel.email,
            error: viewModel.error,
            isLoading: viewModel.isLoading,
            submitTapped: viewModel.addNewContact
        )
        .onChange(of: viewModel.isAddNewContactSuccess) { newValue in
            if newValue {
                // Fix animation when closing the custom alert.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        alertState.dismiss()
                    }
                }
            }
        }
    }
}

struct NewContactContentView: View {
    @Binding var email: String
    let error: String?
    let isLoading: Bool
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
                
                Button{
                    submitTapped()
                } label: {
                    loadingButtonLabel(title: "Submit")
                        .font(.headline)
                        .foregroundStyle(.background)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.ctOrange, in: .rect(cornerRadius: 8))
                }
            }
        }
        .disabled(isLoading)
    }
    
    @ViewBuilder
    private func loadingButtonLabel(title: String) -> some View {
        if isLoading {
            ProgressView()
                .tint(.white)
        } else {
            Text(title)
        }
    }
}

#Preview {
    NewContactContentView(
        email: .constant(""),
        error: nil,
        isLoading: false,
        submitTapped: {}
    )
}
