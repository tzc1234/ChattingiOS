//
//  MessageListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct MessageListView: View {
    @ObservedObject var viewModel: MessageListViewModel
    
    var body: some View {
        MessageListContentView(
            responderName: viewModel.username,
            avatarURL: viewModel.avatarURL,
            messages: viewModel.messages,
            isLoading: viewModel.isLoading,
            generalError: $viewModel.generalError,
            inputMessage: $viewModel.inputMessage,
            messageSent: viewModel.messageSent,
            sendMessage: viewModel.sendMessage,
            loadMoreMessages: viewModel.loadMoreMessages
        )
        .task {
            await viewModel.loadMessages()
            await viewModel.establishChannel()
        }
    }
}

struct MessageListContentView: View {
    let responderName: String
    let avatarURL: URL?
    let messages: [DisplayedMessage]
    let isLoading: Bool
    @Binding var generalError: String?
    @Binding var inputMessage: String
    let messageSent: Bool
    let sendMessage: () -> Void
    let loadMoreMessages: () -> Void
    
    private var firstUnreadMessageID: Int? {
        messages.first { !$0.isRead }?.id
    }
    
    @FocusState private var textEditorFocused: Bool
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                ScrollViewReader { scrollViewProxy in
                    List(messages) { message in
                        MessageView(width: proxy.size.width * 0.7, message: message)
                            .id(message.id)
                            .listRowSeparator(.hidden)
                            .onAppear {
                                if message == messages.last {
                                    loadMoreMessages()
                                }
                            }
                    }
                    .listStyle(.plain)
                    .onChange(of: firstUnreadMessageID) { newValue in
                        if let newValue {
                            scrollViewProxy.scrollTo(newValue)
                        }
                    }
                    .onChange(of: messages) { messages in
                        if messageSent {
                            messages.last.map { scrollViewProxy.scrollTo($0.id) }
                        }
                    }
                }
            }
            
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
            .padding(.vertical, 8)
            .padding(.horizontal, 18)
            .fixedSize(horizontal: false, vertical: true)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
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
                DisplayedMessage(id: 0, text: "Hi!", isMine: false, isRead: true, date: .now),
                DisplayedMessage(id: 1, text: "Yo!", isMine: true, isRead: true, date: .now)
            ],
            isLoading: false,
            generalError: .constant(nil),
            inputMessage: .constant(""),
            messageSent: false,
            sendMessage: {},
            loadMoreMessages: {}
        )
    }
}
