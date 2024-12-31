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
    
    func showAlert<Content: View>(isPresenting: Binding<Bool>, content: @escaping () -> Content) {
        guard let window, window.rootViewController == nil else { return }
        
        let viewController = UIHostingController(
            rootView: AlertContentView(
                isPresenting: isPresenting,
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

private struct AlertContentView<Content: View>: View {
    @State private var showContent = false
    
    @Binding var isPresenting: Bool
    let content: () -> Content
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .onTapGesture {
                    withAnimation {
                        showContent = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        isPresenting = false
                    }
                }
            
            content()
                .scaleEffect(showContent ? 1 : 0)
        }
        .ignoresSafeArea()
        .opacity(showContent ? 1 : 0)
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
}

extension View {
    func customAlert<Content: View>(isPresenting: Binding<Bool>, content: @escaping () -> Content) -> some View {
        modifier(AlertModifier(isPresenting: isPresenting, alertContent: content))
    }
}

private struct AlertModifier<AlertContent: View>: ViewModifier {
    @EnvironmentObject private var sceneDelegate: SceneDelegate
    
    @Binding var isPresenting: Bool
    let alertContent: () -> AlertContent
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresenting) { newValue in
                if newValue {
                    sceneDelegate.showAlert(isPresenting: $isPresenting, content: alertContent)
                } else {
                    sceneDelegate.hideAlert()
                }
            }
    }
}
