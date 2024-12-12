//
//  MessageListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct MessageListView: View {
    @State private var message = ""
    @FocusState private var textEditorFocused: Bool
    
    let username: String
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                let width = proxy.size.width * 0.7
                List(0..<20, id: \.self) { index in
                    MessageView(
                        width: width,
                        text: "\(Int.random(in: 0...999999999999999)) \(Int.random(in: 0...999999999999999)) 3142342134324",
                        isMine: index % 2 == 0
                    )
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            
            HStack(alignment: .top) {
                TextEditor(text: $message)
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
                    Image(systemName: "person.circle")
                    Text(username)
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MessageListView(username: "User 1")
    }
}
