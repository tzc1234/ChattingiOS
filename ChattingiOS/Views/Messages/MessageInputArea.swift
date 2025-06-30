//
//  MessageInputArea.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 12/06/2025.
//

import SwiftUI

struct MessageInputArea: View {
    @Environment(ViewStyleManager.self) private var style
    @State private var textEditorHeight: CGFloat = 35
    
    @Binding var inputMessage: String
    @FocusState var focused: Bool
    let sendButtonIcon: String
    let sendButtonActive: Bool
    let isLoading: Bool
    let sendAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            PreciseTextEditor(text: $inputMessage, height: $textEditorHeight)
                .focused($focused)
                .foregroundColor(style.message.input.foregroundColor)
                .frame(height: textEditorHeight)
                .padding(.horizontal, 8)
                .background {
                    RoundedRectangle(cornerRadius: style.message.input.cornerRadius)
                        .fill(style.message.input.backgroundColor)
                        .overlay(
                            style.message.input.strokeColor,
                            in: .rect(cornerRadius: style.message.input.cornerRadius).stroke(lineWidth: 1)
                        )
                }
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                sendAction()
                focused = false
            } label: {
                loadingButtonLabel
                    .frame(width: 35, height: 35)
                    .background(style.message.input.sendButtonBackground(isActive: sendButtonActive), in: .circle)
                    .scaleEffect(sendButtonActive ? 1 : 0.9)
                    .defaultAnimation(value: sendButtonActive)
            }
            .disabled(!sendButtonActive)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var loadingButtonLabel: some View {
        if isLoading {
            ProgressView()
                .tint(style.message.input.spinnerColor)
        } else {
            Image(systemName: sendButtonIcon)
                .font(.system(size: 18).weight(.medium))
                .foregroundColor(style.message.input.iconColor)
        }
    }
}

struct PreciseTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    let minHeight: CGFloat
    let maxHeight: CGFloat
    
    init(text: Binding<String>, height: Binding<CGFloat>, minHeight: CGFloat = 35, maxHeight: CGFloat = 100) {
        self._text = text
        self._height = height
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .callout)
        textView.isScrollEnabled = false
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        context.coordinator.textView = textView
        return textView
    }
    
    func updateUIView(_ uiTextView: UITextView, context: Context) {
        if uiTextView.text != text {
            uiTextView.text = text
        }
        context.coordinator.updateTextViewHeight()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        var textView: UITextView?
        let parent: PreciseTextEditor
        
        init(_ parent: PreciseTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            updateTextViewHeight()
        }
        
        func updateTextViewHeight() {
            guard let textView else { return }
            
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude))
            let newHeight = max(parent.minHeight, min(parent.maxHeight, size.height))
            
            if newHeight != parent.height {
                DispatchQueue.main.async {
                    self.parent.height = newHeight
                }
            }
            
            textView.isScrollEnabled = size.height > parent.maxHeight
        }
    }
}
