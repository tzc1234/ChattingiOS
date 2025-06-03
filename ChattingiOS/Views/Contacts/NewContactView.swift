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
