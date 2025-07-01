//
//  NewContactView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 30/12/2024.
//

import SwiftUI

struct NewContactView: View {
    @Bindable var viewModel: NewContactViewModel
    @Binding var alertState: AlertState
    let onDismiss: (Contact) -> Void
    
    var body: some View {
        NewContactContentView(
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
        .onChange(of: viewModel.contact) { _, contact in
            if let contact {
                // Fix animation when closing the custom alert.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation { alertState.dismiss() }
                    onDismiss(contact)
                }
            }
        }
    }
}
