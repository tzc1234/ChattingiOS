//
//  ContactListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactListView<AlertContent: View>: View {
    @EnvironmentObject private var style: ViewStyleManager
    @State private var alertState = AlertState()
    
    @Bindable var viewModel: ContactListViewModel
    @ViewBuilder let alertContent: (Binding<AlertState>) -> AlertContent
    let rowTapped: (Contact) -> Void
    
    var body: some View {
        ContactListContentView(
            contacts: viewModel.contacts,
            message: $viewModel.message,
            isLoading: viewModel.isLoading,
            loadMoreContacts: viewModel.loadMoreContacts,
            blockContact: viewModel.blockContact,
            unblockContact: viewModel.unblockContact,
            canUnblock: viewModel.canUnblock,
            rowTapped: rowTapped,
            loadAvatarData: viewModel.loadAvatarData
        )
        .task { await viewModel.loadContacts() }
        .refreshable { await viewModel.loadContacts() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    alertState.present()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(style.button.foregroundColor)
                }
            }
        }
        .alert(alertState: $alertState) {
            alertContent($alertState)
        }
        .alert("⚠️Oops!", isPresented: $viewModel.generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.generalError ?? "")
        }
    }
}
