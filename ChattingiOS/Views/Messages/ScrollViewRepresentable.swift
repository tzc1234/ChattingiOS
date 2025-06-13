//
//  ScrollViewRepresentable.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 12/06/2025.
//

import SwiftUI

struct ScrollViewRepresentable<Content: View>: UIViewRepresentable {
    @Binding var scrollOffset: CGPoint
    let contentInsets: UIEdgeInsets
    let content: () -> Content
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        
        let hostingController = UIHostingController(rootView: content())
        hostingController.view.backgroundColor = .clear
        scrollView.addSubview(hostingController.view)
        
        context.coordinator.hostingController = hostingController
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.hostingController?.rootView = content()
        
        guard let hostingView = context.coordinator.hostingController?.view else { return }
        
        let fittingSize = hostingView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let contentWidth = fittingSize.width
        let contentHeight = fittingSize.height
        
        hostingView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        
        if scrollView.contentInset != contentInsets {
            DispatchQueue.main.async {
                scrollView.contentInset = contentInsets
            }
        }
        
        if scrollView.contentOffset != scrollOffset {
            DispatchQueue.main.async {
                scrollView.setContentOffset(scrollOffset, animated: false)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: ScrollViewRepresentable
        var hostingController: UIHostingController<Content>?
        
        init(_ parent: ScrollViewRepresentable) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.parent.scrollOffset = scrollView.contentOffset
            }
        }
    }
}
