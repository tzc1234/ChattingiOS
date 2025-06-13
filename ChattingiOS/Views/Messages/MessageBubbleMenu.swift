//
//  MessageBubbleMenu.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 12/06/2025.
//

import SwiftUI

struct SelectedBubble: Equatable {
    let frame: CGRect
    let message: DisplayedMessage
}

struct MessageBubbleMenu: View {
    @EnvironmentObject private var style: ViewStyleManager
    
    @FocusState private var editAreaFocused: Bool
    @State private var showMenuItems = false
    @State private var showEditArea = false
    @State private var scrollViewContentID = UUID()
    
    @State private var keyboardHeight: CGFloat = .zero
    @State private var bubbleDifferenceY: CGFloat = .zero
    @State private var menuFrame: CGRect = .zero
    @State private var editText = ""
    @State private var editAreaFrame: CGRect = .zero
    @State private var currentBubbleFrame: CGRect = .zero
    @State private var scrollOffset: CGPoint = .zero
    
    private var message: DisplayedMessage { selectedBubble.message }
    private var bubbleFrame: CGRect { selectedBubble.frame }
    private var verticalSpacing: CGFloat { 8 }
    private var menuOffsetY: CGFloat {
        let offsetY = (menuFrame.height + bubbleFrame.height) / 2 + verticalSpacing
        let menuMaxY = bubbleFrame.maxY + menuFrame.height
        let bottom = screenSize.height - bottomInset
        return menuMaxY < bottom ? offsetY : -offsetY
    }
    
    let screenSize: CGSize
    let bottomInset: CGFloat
    let selectedBubble: SelectedBubble
    @Binding var showBubbleMenu: Bool
    let copyAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewRepresentable(
                scrollOffset: $scrollOffset,
                contentInsets: UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            ) {
                ZStack {
                    Color.white.opacity(0.01)
                        .onTapGesture { dismiss() }
                    
                    ZStack {
                        bubbleContent
                        menuItems
                    }
                    .offset(y: -bubbleDifferenceY)
                    .frame(width: screenSize.width, height: screenSize.height)
                }
            }
            .onChange(of: editAreaFrame) { _ in
                guard editAreaFrame.maxY > 0 else { return }
                
                scrollOffset.y += currentBubbleFrame.maxY - editAreaFrame.minY + verticalSpacing
            }
            
            if showEditArea {
                editArea
            }
        }
        .background(.ultraThinMaterial)
        .background {
            GeometryReader { proxy -> Color in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let frame = proxy.frame(in: .global)
                    bubbleDifferenceY = frame.midY - bubbleFrame.midY
                }
                return Color.clear
            }
        }
        .defaultAnimation(duration: 0.3, value: showMenuItems)
        .defaultAnimation(duration: 0.5, value: showEditArea)
        .ignoresSafeArea()
        .keyboardHeight($keyboardHeight)
        .onAppear {
            showMenuItems = true
            scrollViewContentID = UUID()
        }
    }
    
    private var bubbleContent: some View {
        HStack {
            if message.isMine { Spacer() }
            
            MessageBubbleContent(message: message)
                .frame(width: bubbleFrame.width, height: bubbleFrame.height)
                .background {
                    GeometryReader { proxy -> Color in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            let frame = proxy.frame(in: .global)
                            if currentBubbleFrame != frame {
                                currentBubbleFrame = frame
                            }
                        }
                        return Color.clear
                    }
                }
            
            if !message.isMine { Spacer() }
        }
        .padding(.horizontal, 20)
    }
    
    private var menuItems: some View {
        HStack {
            if message.isMine { Spacer() }
            
            VStack(spacing: 0) {
                MessageBubbleMenuButton(title: "Copy", icon: "doc.on.doc", action: copyAction)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(style.message.bubbleMenu.strokeColor)
                
                MessageBubbleMenuButton(title: "Edit", icon: "square.and.pencil") {
                    showMenuItems = false
                    editAreaFocused = true
                    editText = message.text
                    showEditArea = true
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let menuFrame = proxy.frame(in: .global)
                        if self.menuFrame != menuFrame {
                            self.menuFrame = menuFrame
                        }
                    }
                    return Color.clear
                }
            }
            
            if !message.isMine { Spacer() }
        }
        .opacity(showMenuItems ? 1 : 0)
        .offset(y: menuOffsetY)
    }
    
    private var editArea: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Edit Message")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(style.message.bubbleMenu.foregroundColor)
                
                Spacer()
                
                CTCloseButton(size: 24, fontSize: 12, tapAction: dismiss)
            }
            .padding(.top, 12)
            .padding(.horizontal, 22)

            MessageInputArea(
                inputMessage: $editText,
                focused: _editAreaFocused,
                sendButtonActive: !editText.isEmpty,
                isLoading: false,
                sendAction: {}
            )
        }
        .padding(.bottom, bottomInset)
        .background(.ultraThinMaterial)
        .background {
            GeometryReader { proxy -> Color in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let frame = proxy.frame(in: .global)
                    if editAreaFrame != frame {
                        editAreaFrame = frame
                    }
                }
                return Color.clear
            }
        }
        .offset(y: -max((keyboardHeight-bottomInset), 0))
    }
    
    private func dismiss() {
        showMenuItems = false
        showEditArea = false
        showBubbleMenu = false
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
