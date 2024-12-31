//
//  CustomAlertView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 30/12/2024.
//

import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

final class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        window?.isHidden = true
        window?.isUserInteractionEnabled = false
    }
    
    func showAlert<Content: View>(alertState: Binding<AlertState>, content: @escaping () -> Content) {
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
    var showContent = false
    var isPresenting = false
}

private struct AlertContentView<Content: View>: View {
    @Binding var alertState: AlertState
    let content: () -> Content
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .onTapGesture {
                    withAnimation {
                        alertState.showContent = false
                    }
                    alertState.isPresenting = false
                }
            
            content()
                .scaleEffect(alertState.showContent ? 1 : 0)
        }
        .ignoresSafeArea()
        .opacity(alertState.showContent ? 1 : 0)
        .onAppear {
            withAnimation {
                alertState.showContent = true
            }
        }
    }
}

extension View {
    func customAlert<Content: View>(alertState: Binding<AlertState>, content: @escaping () -> Content) -> some View {
        modifier(AlertModifier(alertState: alertState, alertContent: content))
    }
}

private struct AlertModifier<AlertContent: View>: ViewModifier {
    @EnvironmentObject private var sceneDelegate: SceneDelegate
    
    @Binding var alertState: AlertState
    let alertContent: () -> AlertContent
    
    func body(content: Content) -> some View {
        content
            .onChange(of: alertState.isPresenting) { newValue in
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
