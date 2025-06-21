//
//  CustomAlertView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 30/12/2024.
//

import SwiftUI

final class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        window?.isHidden = true
        window?.isUserInteractionEnabled = false
    }
    
    func showAlert<Content: View>(alertState: Binding<AlertState>, @ViewBuilder content: @escaping () -> Content) {
        guard let window, window.rootViewController == nil else { return }
        
        let viewController = UIHostingController(
            rootView: AlertContentView(
                alertState: alertState,
                content: content
            )
        )
        viewController.view.backgroundColor = .clear
        
        window.rootViewController = viewController
        window.isHidden = false
        window.isUserInteractionEnabled = true
    }
    
    func hideAlert() {
        guard let window else { return }
        
        window.rootViewController = nil
        window.isHidden = true
        window.isUserInteractionEnabled = false
    }
}

struct AlertState {
    fileprivate var isShowingContent = false
    fileprivate var isPresenting = false
    
    fileprivate mutating func showContent() {
        isShowingContent = true
    }
    
    mutating func present() {
        isPresenting = true
    }
    
    mutating func dismiss() {
        isShowingContent = false
        isPresenting = false
    }
}

private struct AlertContentView<Content: View>: View {
    @Binding var alertState: AlertState
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .onTapGesture {
                    withAnimation {
                        alertState.dismiss()
                    }
                }
            
            content()
                .scaleEffect(alertState.isShowingContent ? 1 : 0)
        }
        .ignoresSafeArea()
        .opacity(alertState.isShowingContent ? 1 : 0)
        .onAppear {
            withAnimation {
                alertState.showContent()
            }
        }
    }
}

extension View {
    func alert<Content: View>(alertState: Binding<AlertState>,
                              @ViewBuilder content: @escaping () -> Content) -> some View {
        modifier(AlertModifier(alertState: alertState, alertContent: content))
    }
}

private struct AlertModifier<AlertContent: View>: ViewModifier {
    @EnvironmentObject private var sceneDelegate: SceneDelegate
    
    @Binding var alertState: AlertState
    @ViewBuilder let alertContent: () -> AlertContent
    
    func body(content: Content) -> some View {
        content
            .onChange(of: alertState.isPresenting) { _, newValue in
                if newValue {
                    sceneDelegate.showAlert(alertState: $alertState, content: alertContent)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        sceneDelegate.hideAlert()
                    }
                }
            }
    }
}
