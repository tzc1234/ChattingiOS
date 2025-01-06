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
            generalError: $viewModel.generalError
        )
    }
}

struct MessageListContentView: View {
    let responderName: String
    let avatarURL: URL?
    let messages: [DisplayedMessage]
    @Binding var generalError: String?
    
    @State private var inputMessage = ""
    @FocusState private var textEditorFocused: Bool
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                let width = proxy.size.width * 0.7
                List(messages) { message in
                    MessageView(width: width, message: message)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
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
                    textEditorFocused = false
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.ctOrange)
                        .font(.system(size: 30))
                }
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
}

#Preview {
    NavigationStack {
        MessageListContentView(
            responderName: "Jack",
            avatarURL: nil,
            messages: [
                DisplayedMessage(id: 0, text: "Hi!", isMine: false, isRead: true, createdAt: .now),
                DisplayedMessage(id: 1, text: "Yo!", isMine: true, isRead: true, createdAt: .now)
            ],
            generalError: .constant(nil)
        )
    }
}
