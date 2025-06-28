//
//  ScalingLongPressModifier.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 23/06/2025.
//

import SwiftUI

extension View {
    func onCustomLongPressGesture(canTrigger: Bool = true, perform action: @escaping () -> Void) -> some View {
        modifier(CustomLongPressModifier(canTrigger: canTrigger, action: action))
    }
}

struct CustomLongPressModifier: ViewModifier {
    @State private var longPressTask: Task<Void, Never>?
    @State private var shouldScale = false
    
    let canTrigger: Bool
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture(
                minimumDuration: 0.15,
                maximumDistance: 10,
                perform: {},
                onPressingChanged: { isPressing in
                    if canTrigger {
                        handlePressingChange(isPressing: isPressing)
                    }
                }
            )
    }
    
    @MainActor
    private func handlePressingChange(isPressing: Bool) {
        if isPressing {
            longPressTask = Task {
                try? await Task.sleep(for: .seconds(0.2))
                guard !Task.isCancelled else { return }
                
                withAnimation(.spring()) {
                    shouldScale = true
                } completion: {
                    guard !Task.isCancelled else { return }
                    
                    action()
                }
            }
        } else {
            longPressTask?.cancel()
            longPressTask = nil
            
            withAnimation(.spring()) {
                shouldScale = false
            }
        }
    }
}
