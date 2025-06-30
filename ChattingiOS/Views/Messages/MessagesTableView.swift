//
//  MessagesTableView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 25/06/2025.
//

import SwiftUI

struct MessagesTableView<Content: View>: UIViewRepresentable {
    let messages: [DisplayedMessage]
    @ViewBuilder let content: (Int, DisplayedMessage) -> Content
    @Binding var visibleMessageIndex: Set<Int>
    @Binding var listPositionMessageID: Int?
    let bottomSafeAreaInset: CGFloat
    let isLoading: Bool
    @Binding var isScrollToBottom: Bool
    let disabled: Bool
    @FocusState var messageInputFocused: Bool
    let onContentTop: () -> Void
    let onContentBottom: () -> Void
    let onBackgroundTap: (() -> Void)?
    
    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Coordinator.cellID)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.addGestureRecognizer(UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleBackgroundTap)
        ))

        context.coordinator.tableView = tableView
        return tableView
    }
    
    func updateUIView(_ tableView: UITableView, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        
        if coordinator.messages != messages {
            coordinator.messages = messages
            tableView.reloadData()
            
            if let currentTopMessageID = coordinator.currentTopMessageID,
               let index = messages.firstIndex(where: { $0.id == currentTopMessageID }) {
                tableView.scrollToRow(at: IndexPath(row: index, section: 0) , at: .top, animated: false)
                coordinator.currentTopMessageID = nil
            }
        }
        
        updateVisibleMessageIndex(tableView: tableView)
        
        if let listPositionMessageID, let index = messages.firstIndex(where: { $0.id == listPositionMessageID }) {
            DispatchQueue.main.async {
                tableView.scrollToRow(at: IndexPath(row: index, section: 0) , at: .bottom, animated: false)
                self.listPositionMessageID = nil
            }
        }
        
        if isScrollToBottom {
            DispatchQueue.main.async {
                tableView.scrollToRow(at: IndexPath(row: messages.count-1, section: 0) , at: .bottom, animated: true)
                isScrollToBottom = false
            }
        }
        
        tableView.isScrollEnabled = !disabled
        tableView.isUserInteractionEnabled = !disabled
        
        if disabled {
            tableView.contentInset.bottom = coordinator.lastContentOffsetYAdjustment
            messageInputFocused = false
        } else {
            if coordinator.lastContentOffsetYAdjustment > 0 {
                tableView.contentInset.bottom = 0
                coordinator.lastContentOffsetYAdjustment = 0
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateVisibleMessageIndex(tableView: UITableView) {
        DispatchQueue.main.async {
            visibleMessageIndex = Set(tableView.visibleCells.map(\.tag))
        }
    }
    
    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        static var cellID: String { "Cell" }
        
        var tableView: UITableView?
        var currentTopMessageID: Int?
        var messages = [DisplayedMessage]()
        
        private var tableFrameBeforeKeyboardShown: CGRect = .zero
        var lastContentOffsetYAdjustment: CGFloat = 0
        
        var parent: MessagesTableView<Content>
        
        init(_ parent: MessagesTableView<Content>) {
            self.parent = parent
            super.init()
            self.observeKeyboardHeight()
        }
        
        private func observeKeyboardHeight() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillShow(_:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardDidShow(_:)),
                name: UIResponder.keyboardDidShowNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillHide(_:)),
                name: UIResponder.keyboardWillHideNotification,
                object: nil
            )
        }
        
        @objc private func keyboardWillShow(_ notification: Notification) {
            guard !parent.disabled else { return }
            guard let userInfo = notification.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                  let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
                  let tableView else {
                return
            }
            
            let keyboardHeight = keyboardFrame.height
            let previousAdjustment = tableView.contentInset.bottom
            let adjustment = keyboardHeight - parent.bottomSafeAreaInset
            
            tableFrameBeforeKeyboardShown = tableView.frame
            lastContentOffsetYAdjustment = adjustment
            
            let options = UIView.AnimationOptions(rawValue: animationCurve << 16)
            UIView.animate(withDuration: animationDuration, delay: 0, options: options) {
                tableView.contentInset.bottom = adjustment
                tableView.verticalScrollIndicatorInsets.bottom = adjustment
                tableView.contentOffset.y += adjustment - previousAdjustment
            }
        }
        
        @objc private func keyboardDidShow(_ notification: Notification) {
            guard !parent.disabled else { return }
            // The tableView finally updated its height (shorter height).
            guard let tableView, tableView.frame.height < tableFrameBeforeKeyboardShown.height else { return }
            
            tableView.contentInset.bottom = 0
            tableView.verticalScrollIndicatorInsets.bottom = 0
        }
        
        @objc private func keyboardWillHide(_ notification: Notification) {
            guard !parent.disabled else { return }
            guard lastContentOffsetYAdjustment > 0,
                  let userInfo = notification.userInfo,
                  let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                  let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
                  let tableView else {
                return
            }
            
            let adjustment = lastContentOffsetYAdjustment
            let options = UIView.AnimationOptions(rawValue: animationCurve << 16)
            UIView.animate(withDuration: animationDuration, delay: 0, options: options) {
                tableView.contentInset.bottom = 0
                tableView.verticalScrollIndicatorInsets.bottom = 0
                tableView.contentOffset.y -= adjustment
                self.lastContentOffsetYAdjustment = 0
            }
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            messages.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath)
            let message = messages[indexPath.row]
            let swiftUIView = parent.content(indexPath.row, message)
            
            cell.contentConfiguration = UIHostingConfiguration {
                swiftUIView
            }
            .margins(.horizontal, 20)
            .margins(.vertical, 8)
            .background(.clear)
            
            cell.tag = indexPath.row
            return cell
        }
        
        @objc func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
            parent.onBackgroundTap?()
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if let tableView = scrollView as? UITableView {
                parent.updateVisibleMessageIndex(tableView: tableView)
            }
            
            let offsetY = scrollView.contentOffset.y
            if offsetY == 0, !parent.isLoading {
                currentTopMessageID = messages.first?.id
                parent.onContentTop()
                return
            }
            
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.frame.size.height
            if offsetY > contentHeight - scrollViewHeight, !parent.isLoading {
                parent.onContentBottom()
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
