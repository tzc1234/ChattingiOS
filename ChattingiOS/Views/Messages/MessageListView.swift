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
            avatarURL: viewModel.avatarURL,
            messages: viewModel.messages,
            isLoading: viewModel.isLoading,
            isBlocked: viewModel.isBlocked,
            generalError: $viewModel.generalError,
            setupError: $viewModel.setupError,
            inputMessage: $viewModel.inputMessage,
            listPositionMessageID: $viewModel.messageIDForListPosition,
            setupList: viewModel.setupMessageList,
            sendMessage: viewModel.sendMessage,
            loadPreviousMessages: viewModel.loadPreviousMessages,
            loadMoreMessages: viewModel.loadMoreMessages,
            readMessages: viewModel.readMessages,
            isConnecting: viewModel.isConnecting
        )
        .toolbar(.hidden, for: .tabBar)
        .onAppear { viewModel.setupMessageList() }
        .onDisappear { viewModel.closeMessageChannel() }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                viewModel.setupMessageList()
            } else if phase == .inactive {
                viewModel.closeMessageChannel()
            }
        }
    }
}

struct MessageListContentView: View {
    let responderName: String
    let avatarURL: URL?
    let messages: [DisplayedMessage]
    let isLoading: Bool
    let isBlocked: Bool
    @Binding var generalError: String?
    @Binding var setupError: String?
    @Binding var inputMessage: String
    @Binding var listPositionMessageID: Int?
    let setupList: () -> Void
    let sendMessage: () -> Void
    let loadPreviousMessages: () -> Void
    let loadMoreMessages: () -> Void
    let readMessages: (Int) -> Void
    let isConnecting: Bool
    
    @FocusState private var textEditorFocused: Bool
    @State private var scrollToMessageID: Int?
    @State private var showSetupError = false
    
    var body: some View {
        VStack {
            setupErrorView
                .onChange(of: setupError) { error in
                    withAnimation { showSetupError = error != nil }
                }
            
            GeometryReader { proxy in
                ScrollViewReader { scrollViewProxy in
                    List(messages) { message in
                        MessageView(width: proxy.size.width, message: message)
                            .id(message.id)
                            .listRowSeparator(.hidden)
                            .onAppear {
                                if message == messages.first {
                                    loadPreviousMessages()
                                } else if message == messages.last {
                                    loadMoreMessages()
                                }
                                
                                if message.isUnread {
                                    readMessages(message.id)
                                }
                            }
                    }
                    .listStyle(.plain)
                    .onChange(of: listPositionMessageID) { messageID in
                        if let messageID {
                            withAnimation {
                                scrollToMessageID = messageID
                            }
                            listPositionMessageID = nil
                        }
                    }
                    .onChange(of: scrollToMessageID) { messageID in
                        scrollViewProxy.scrollTo(messageID, anchor: .top)
                    }
                }
            }
            
            if !isBlocked {
                HStack(alignment: .top) {
                    TextEditor(text: $inputMessage)
                        .font(.callout)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.secondary, lineWidth: 1)
                        )
                        .clipShape(.rect(cornerRadius: 8))
                        .focused($textEditorFocused)
                    
                    Button {
                        sendMessage()
                        textEditorFocused = false
                    } label: {
                        loadingButtonLabel
                            .frame(width: 35, height: 35)
                            .background(Color.ctOrange)
                            .clipShape(.circle)
                    }
                    .disabled(isLoading)
                    .disabled(inputMessage.isEmpty)
                    .brightness(isLoading || inputMessage.isEmpty ? -0.1 : 0)
                }
                .disabled(!isConnecting)
                .brightness(isConnecting ? 0 : -0.1)
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onTapGesture { textEditorFocused = false }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    AsyncImage(url: avatarURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle")
                            .font(.system(size: 25))
                    }
                    .frame(width: 30, height: 30)
                    .clipShape(.circle)
                    
                    Text(responderName)
                        .font(.headline)
                }
            }
        }
        .alert("⚠️Oops!", isPresented: $generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(generalError ?? "")
        }
    }
    
    @ViewBuilder
    private var setupErrorView: some View {
        if showSetupError {
            HStack {
                Text((setupError ?? "") + " Switch to read-only mode.")
                    .foregroundStyle(.white)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button("Connect") {
                    setupError = nil
                    setupList()
                }
                .foregroundStyle(.ctRed)
                .padding(10)
                .background(.background, in: .rect(cornerRadius: 8))
            }
            .font(.subheadline)
            .padding(.horizontal, 20)
            .background(.ctRed, in: .rect)
        }
    }
    
    @ViewBuilder
    private var loadingButtonLabel: some View {
        if isLoading {
            ProgressView()
                .tint(.white)
        } else {
            Image(systemName: "arrow.right")
                .foregroundStyle(.white)
                .font(.system(size: 18))
        }
    }
}

#Preview {
    NavigationStack {
        MessageListContentView(
            responderName: "Jack",
            avatarURL: nil,
            messages: [
                DisplayedMessage(id: 0, text: "Hi!", isMine: false, isRead: true, date: "01/01/2025, 10:00"),
                DisplayedMessage(id: 1, text: "Yo!", isMine: true, isRead: true, date: "01/01/2025, 10:01")
            ],
            isLoading: false,
            isBlocked: false,
            generalError: .constant(nil),
            setupError: .constant(nil),
            inputMessage: .constant(""),
            listPositionMessageID: .constant(nil),
            setupList: {},
            sendMessage: {},
            loadPreviousMessages: {},
            loadMoreMessages: {},
            readMessages: { _ in },
            isConnecting: true
        )
    }
}
