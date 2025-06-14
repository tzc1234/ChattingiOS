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
    @State private var showMenuItems = true
    @State private var showEditArea = false
    
    @State private var keyboardHeight: CGFloat = .zero
    @State private var menuFrame: CGRect = .zero
    @State private var currentBubbleFrame: CGRect = .zero
    @State private var editText = ""
    @State private var editAreaFrame: CGRect = .zero
    @State private var scrollOffset: CGPoint = .zero
    
    @State private var contentMinY: CGFloat = .zero
    @State private var bubbleDifferenceMinY: CGFloat = .zero
    @State private var currentBubbleMaxY: CGFloat = .zero
    @State private var editAreaMinY: CGFloat = .zero
    
    private var message: DisplayedMessage { selectedBubble.message }
    private var bubbleFrame: CGRect { selectedBubble.frame }
    
    let screenSize: CGSize
    let bottomInset: CGFloat
    let selectedBubble: SelectedBubble
    @Binding var showBubbleMenu: Bool
    let copyAction: () -> Void
    
    private var contentInsets: UIEdgeInsets {
        if bubbleDifferenceMinY > 0 {
            UIEdgeInsets(top: bubbleDifferenceMinY, left: 0, bottom: 0, right: 0)
        } else {
            UIEdgeInsets(top: 0, left: 0, bottom: abs(bubbleDifferenceMinY), right: 0)
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                DispatchQueue.main.async {
                    let frame = proxy.frame(in: .global)
                    contentMinY = frame.minY
                    bubbleDifferenceMinY = bubbleFrame.minY - frame.minY
                }
                return Color.white.opacity(0.01)
            }
            
            VStack(spacing: 0) {
                ScrollViewRepresentable(
                    scrollOffset: $scrollOffset,
                    contentInsets: contentInsets,
                    onBackgroundTap: { dismiss() }
                ) {
                    VStack {
                        bubbleContent
                        menuItems
                    }
                    .frame(width: screenSize.width)
                }
                
                if showEditArea {
                    editArea
                }
            }
            .onChange(of: keyboardHeight) { _ in
                if keyboardHeight > 0 {
                    updateScrollOffsetY()
                }
            }
        }
        .background(.ultraThinMaterial)
        .defaultAnimation(duration: 0.3, value: showMenuItems)
        .defaultAnimation(duration: 0.5, value: showEditArea)
        .keyboardHeight($keyboardHeight, type: .didShow)
    }
    
    private func updateScrollOffsetY() {
        let verticalSpacing: CGFloat = 8
        scrollOffset.y += currentBubbleMaxY - editAreaMinY + verticalSpacing
    }
    
    private var bubbleContent: some View {
        HStack {
            if message.isMine { Spacer() }
            
            MessageBubbleContent(message: message)
                .frame(width: bubbleFrame.width, height: bubbleFrame.height)
                .background {
                    GeometryReader { proxy -> Color in
                        DispatchQueue.main.async {
                            let frame = proxy.frame(in: .global)
                            if currentBubbleMaxY != frame.maxY.rounded() {
                                currentBubbleMaxY = frame.maxY.rounded()
                            }
                            
                            if currentBubbleFrame != frame {
                                currentBubbleFrame = frame
                                print("currentBubbleFrame maxY: \(currentBubbleFrame.maxY)")
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
            
            if !message.isMine { Spacer() }
        }
        .opacity(showMenuItems ? 1 : 0)
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
        .background(.ultraThinMaterial)
        .background {
            GeometryReader { proxy -> Color in
                DispatchQueue.main.async {
                    let frame = proxy.frame(in: .global)
                    if editAreaMinY != frame.minY.rounded() {
                        editAreaMinY = frame.minY.rounded()
                    }
                    
                    if editAreaFrame != frame {
                        editAreaFrame = frame
                        print("editAreaFrame maxY: \(editAreaFrame.minY)")
                    }
                }
                return Color.clear
            }
        }
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
