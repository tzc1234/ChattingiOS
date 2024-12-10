//
//  MessageListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct MessageListView: View {
    var body: some View {
        GeometryReader { proxy in
            List(0..<20, id: \.self) { index in
                MessageView(
                    width: proxy.size.width * 0.7,
                    text: "Hello \(Int.random(in: 0...999999999999999)) \(Int.random(in: 0...999999999999999)) 3142342134324",
                    isMine: index % 2 == 0
                )
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MessageListView()
}
