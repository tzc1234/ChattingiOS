//
//  MessagesTableView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 25/06/2025.
//

import SwiftUI

struct MessagesTableView<Content: View>: UIViewRepresentable {
    let messages: [DisplayedMessage]
    @ViewBuilder let content: (Int, DisplayedMessage, [DisplayedMessage]) -> Content
    @Binding var visibleMessageIndex: Set<Int>
    let isLoading: Bool
    @Binding var isScrollToBottom: Bool
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
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        tableView.addGestureRecognizer(tapGesture)
        
        return tableView
    }
    
    func updateUIView(_ tableView: UITableView, context: Context) {
        let coordinator = context.coordinator
        coordinator.isLoading = isLoading
        
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
        
        if isScrollToBottom {
            DispatchQueue.main.async {
                tableView.scrollToRow(at: IndexPath(row: messages.count-1, section: 0) , at: .bottom, animated: true)
                isScrollToBottom = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    private func updateVisibleMessageIndex(tableView: UITableView) {
        DispatchQueue.main.async {
            visibleMessageIndex = Set(tableView.visibleCells.map(\.tag))
        }
    }
    
    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        static var cellID: String { "Cell" }
        
        var currentTopMessageID: Int?
        var messages = [DisplayedMessage]()
        private var lastContentOffset: CGFloat = 0
        
        private let parent: MessagesTableView<Content>
        var isLoading: Bool
        
        init(parent: MessagesTableView<Content>) {
            self.parent = parent
            self.isLoading = parent.isLoading
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            messages.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath)
            let message = messages[indexPath.row]
            let swiftUIView = parent.content(indexPath.row, message, messages)
            
            cell.contentConfiguration = UIHostingConfiguration {
                swiftUIView
            }
            .margins(.horizontal, 20)
            .margins(.vertical, 8)
            .background(.clear)
            
            cell.tag = indexPath.row
            return cell
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
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
    }
}
