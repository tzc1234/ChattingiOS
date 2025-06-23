//
//  SearchView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 23/06/2025.
//

import SwiftUI

struct SearchView: View {
    @Bindable var viewModel: SearchViewModel
    let rowTapped: (Contact) -> Void
    
    var body: some View {
        SearchContentView(
            contacts: viewModel.contacts,
            searchTerm: $viewModel.searchTerm,
            isLoading: viewModel.isLoading,
            searchContacts: viewModel.searchContacts,
            searchMoreContacts: viewModel.searchMoreContacts,
            loadAvatarData: viewModel.loadAvatarData(url:),
            rowTapped: rowTapped
        )
        .alert("⚠️Oops!", isPresented: $viewModel.generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.generalError ?? "")
        }
    }
}
