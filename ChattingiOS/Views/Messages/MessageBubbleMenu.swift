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
    @State private var screenBottom: CGFloat = .zero
    @State private var bubbleDifferenceY: CGFloat = .zero
    @State private var menuFrame: CGRect = .zero
    @State private var showMenuItems = false
    @State private var showEditArea = false
    @State private var editText = ""
    @FocusState private var editAreaFocused: Bool
    
    private var message: DisplayedMessage { selectedBubble.message }
    private var bubbleFrame: CGRect { selectedBubble.frame }
    private var menuOffsetY: CGFloat {
        let spacing: CGFloat = 8
        let offsetY = (menuFrame.height + bubbleFrame.height) / 2 + spacing
        let menuMaxY = bubbleFrame.maxY + menuFrame.height
        return menuMaxY < screenBottom ? offsetY : -offsetY
    }
    
    let selectedBubble: SelectedBubble
    let copyAction: () -> Void
    
    var body: some View {
        ZStack {
            ZStack {
                Color.white.opacity(0.001)
                    .background(.ultraThinMaterial)
                
                MessageBubbleContent(message: message)
                    .frame(width: bubbleFrame.width, height: bubbleFrame.height)
                    .position(x: bubbleFrame.midX, y: bubbleFrame.midY)
                
                HStack {
                    if message.isMine { Spacer() }
                    
                    VStack(spacing: 0) {
                        MessageBubbleMenuButton(title: "Copy", icon: "doc.on.doc", action: copyAction)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(style.message.bubbleMenu.strokeColor)
                        
                        MessageBubbleMenuButton(title: "Edit", icon: "square.and.pencil") {
                            showMenuItems = false
                            showEditArea = true
                            editAreaFocused = true
                            editText = message.text
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
                    .offset(y: menuOffsetY)
                    
                    if !message.isMine { Spacer() }
                }
                .opacity(showMenuItems ? 1 : 0)
            }
            .background {
                GeometryReader { proxy -> Color in
                    DispatchQueue.main.async {
                        let frame = proxy.frame(in: .global)
                        bubbleDifferenceY = frame.midY - bubbleFrame.midY
                    }
                    return Color.clear
                }
            }
            .ignoresSafeArea()
            
            editArea
                .opacity(showEditArea ? 1 : 0)
        }
        .defaultAnimation(value: showMenuItems)
        .defaultAnimation(value: showEditArea)
        .onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                screenBottom = windowScene.screen.bounds.size.height - keyWindow.safeAreaInsets.bottom
            }
            
            showMenuItems = true
        }
    }
    
    private var editArea: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 12) {
                HStack {
                    Text("Edit Message")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(style.message.bubbleMenu.foregroundColor)
                    
                    Spacer()
                    
                    CTCloseButton(size: 22, fontSize: 12) {
                        showEditArea = false
                        editAreaFocused = false
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 22)

                MessageInputArea(
                    inputMessage: $editText,
                    focused: _editAreaFocused,
                    sendButtonActive: !editText.isEmpty,
                    isLoading: false,
                    sendAction: {}
                )
            }
            .background { style.message.input.sectionBackground }
        }
    }
}

struct MessageBubbleMenuButton: View {
    @EnvironmentObject private var style: ViewStyleManager
    
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline.weight(.medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .foregroundColor(style.message.bubbleMenu.foregroundColor)
                .background(style.message.bubbleMenu.backgroundColor)
        }
    }
}
