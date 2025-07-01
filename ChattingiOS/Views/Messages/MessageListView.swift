//
//  MessageListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct MessageListView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @Bindable var viewModel: MessageListViewModel
    
    var body: some View {
        MessageListContentView(
            responderName: viewModel.username,
            avatarData: viewModel.avatarData,
            messages: viewModel.messages,
            isLoading: viewModel.isLoading,
            blockedState: viewModel.blockedState,
            isConnecting: viewModel.isConnecting,
            setupError: $viewModel.setupError,
            listPositionMessageID: $viewModel.messageIDForListPosition,
            setupList: viewModel.setupMessageList,
            loadPreviousMessages: viewModel.loadPreviousMessages,
            loadMoreMessages: viewModel.loadMoreMessages,
            readMessages: viewModel.readMessages,
            sendMessage: .init(
                inputMessage: $viewModel.inputMessage,
                canSendMessage: viewModel.canSendMessage,
                sendMessage: viewModel.sendMessage
            ),
            editMessage: .init(
                shouldShowEdit: viewModel.shouldShowEdit(_:),
                canEdit: viewModel.canEdit(for:text:),
                editMessage: viewModel.editMessage(messageID:text:),
            ),
            deleteMessage: .init(
                shouldShowDelete: viewModel.shouldShowDelete(_:),
                deleteMessage: viewModel.deleteMessage(_:)
            )
        )
        .toolbar(.hidden, for: .tabBar)
        .task { await viewModel.loadAvatarData() }
        .onAppear { viewModel.setupMessageList() }
        .onDisappear { viewModel.closeMessageChannel() }
        .onChange(of: scenePhase) { _, phase in
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
