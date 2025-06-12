//
//  MessageBubbleMenu.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 12/06/2025.
//

import SwiftUI

struct SelectedBubble {
    let frame: CGRect
    let message: DisplayedMessage
}

struct MessageBubbleMenu: View {
    @EnvironmentObject private var style: ViewStyleManager
    @State private var screenSize: CGSize = .zero
    @State private var bottomInset: CGFloat = .zero
    @State private var bubbleDifferenceY: CGFloat = .zero
    @State private var menuFrame: CGRect = .zero
    
    private var message: DisplayedMessage { selectedBubble.message }
    private var bubbleFrame: CGRect { selectedBubble.frame }
    
    private func menuOffsetY(_ bubbleFrame: CGRect) -> CGFloat {
        let spacing: CGFloat = 8
        let offsetY = (menuFrame.height + bubbleFrame.height) / 2 + spacing
        let menuMaxY = bubbleFrame.maxY + menuFrame.height
        let bottom = screenSize.height - bottomInset
        return menuMaxY < bottom ? offsetY : -offsetY
    }
    
    let selectedBubble: SelectedBubble
    let copyAction: () -> Void
    let editAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
            
            MessageBubbleContent(message: message)
                .frame(width: bubbleFrame.width, height: bubbleFrame.height)
                .position(x: bubbleFrame.midX, y: bubbleFrame.midY)
                .background {
                    GeometryReader { proxy -> Color in
                        DispatchQueue.main.async {
                            let frame = proxy.frame(in: .global)
                            bubbleDifferenceY = frame.midY - bubbleFrame.midY
                        }
                        return Color.clear
                    }
                }
            
            HStack {
                if message.isMine { Spacer() }
                
                VStack(spacing: 0) {
                    Button(action: copyAction) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.headline.weight(.medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .foregroundColor(style.message.bubbleMenu.foregroundColor)
                            .background(style.message.bubbleMenu.backgroundColor)
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(style.message.bubbleMenu.strokeColor)
                    
                    Button(action: editAction) {
                        Label("Edit", systemImage: "square.and.pencil")
                            .font(.headline.weight(.medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .foregroundColor(style.message.bubbleMenu.foregroundColor)
                            .background(style.message.bubbleMenu.backgroundColor)
                    }
                }
                .frame(width: 200)
                .clipShape(.rect(cornerRadius: style.message.bubbleMenu.cornerRadius))
                .overlay(
                    style.message.bubbleMenu.strokeColor,
                    in: .rect(cornerRadius: style.message.bubbleMenu.cornerRadius).stroke(lineWidth: 1))
                .padding(.horizontal, 20)
                .background {
                    GeometryReader { proxy -> Color in
                        DispatchQueue.main.async {
                            let menuFrame = proxy.frame(in: .global)
                            if self.menuFrame != menuFrame {
                                self.menuFrame = menuFrame
                            }
                        }
                        return Color.clear
                    }
                }
                .offset(y: -bubbleDifferenceY)
                .offset(y: menuOffsetY(bubbleFrame))
                
                if !message.isMine { Spacer() }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
        .onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                screenSize = windowScene.screen.bounds.size
                bottomInset = keyWindow.safeAreaInsets.bottom
            }
        }
    }
}
