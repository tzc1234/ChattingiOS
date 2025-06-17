//
//  MessageListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct MessageListView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject var viewModel: MessageListViewModel
    
    var body: some View {
        MessageListContentView(
            responderName: viewModel.username,
            avatarData: viewModel.avatarData,
            messages: viewModel.messages,
            isLoading: viewModel.isLoading,
            isBlocked: viewModel.isBlocked,
            isConnecting: viewModel.isConnecting,
            setupError: $viewModel.setupError,
            inputMessage: $viewModel.inputMessage,
            listPositionMessageID: $viewModel.messageIDForListPosition,
            setupList: viewModel.setupMessageList,
            sendMessage: viewModel.sendMessage,
            loadPreviousMessages: viewModel.loadPreviousMessages,
            loadMoreMessages: viewModel.loadMoreMessages,
            readMessages: viewModel.readMessages,
            editMessage: .init(
                editMessageInput: $viewModel.editMessageInput,
                editMessage: viewModel.editMessage(messageID:),
                shouldShowEdit: viewModel.shouldShowEdit(_:),
                canEdit: viewModel.canEdit(for:)
            )
        )
        .toolbar(.hidden, for: .tabBar)
        .task { await viewModel.loadAvatarData() }
        .onAppear { viewModel.setupMessageList() }
        .onDisappear { viewModel.closeMessageChannel() }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                viewModel.setupMessageList()
            } else if phase == .inactive {
                viewModel.closeMessageChannel()
            }
        }
        .alert("⚠️Oops!", isPresented: $viewModel.generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.generalError ?? "")
        }
    }
}
