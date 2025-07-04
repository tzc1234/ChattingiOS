//
//  SearchContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 23/06/2025.
//

import SwiftUI

struct SearchContentView: View {
    private enum SearchScope: String, CaseIterable {
        case contacts = "Contacts"
        case messages = "Messages"
    }
    
    @Environment(ViewStyleManager.self) private var style
    @FocusState private var focused: Bool
    @State private var searchScope: SearchScope = .contacts
    @State private var selectedContactID: Int?
    @State private var searchBarID = UUID()
    
    let contactsResult: SearchContactsResult
    @Binding var searchTerm: String
    let isLoading: Bool
    let searchContacts: () -> Void
    let searchMoreContacts: () -> Void
    let loadAvatarData: (URL) async -> Data?
    let rowTapped: (Contact) -> Void
    
    var body: some View {
        ZStack {
            CTBackgroundView()
                .onTapGesture { focused = false }
            
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    enhancedSearchBar
                        .id(searchBarID)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
                
                if searchTerm.isEmpty {
                    emptySearchState
                } else {
                    searchResultsList
                }
            }
            .defaultAnimation(duration: 0.1, value: searchTerm)
            .defaultAnimation(duration: 0.3, value: searchScope)
            .defaultAnimation(duration: 0.3, value: contactsResult)
            .padding(.top, 12)
        }
        .navigationTitle("Search")
        .onAppear {
            if searchTerm.isEmpty || contactsResult.contacts.isEmpty {
                searchBarID = UUID()
                focused = true
            }
        }
        .onChange(of: searchTerm) { _, _ in
            searchContacts()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focused = true
            }
        }
    }
    
    private var enhancedSearchBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .controlSize(.regular)
                        .tint(.blue)
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(style.search.iconColor(isActive: !searchTerm.isEmpty))
                }
                    
                TextField(searchScope == .contacts ? "Search contacts..." : "Search messages...", text: $searchTerm)
                    .font(.body.weight(.medium))
                    .foregroundColor(style.search.textColor)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focused)
                
                Button {
                    searchTerm = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(style.button.close.foregroundColor)
                }
                .transition(.scale.combined(with: .opacity))
                .opacity(searchTerm.isEmpty ? 0 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: style.search.cornerRadius)
                    .fill(style.search.backgroundColor)
                    .overlay(
                        style.search.defaultStrokeColor,
                        in: .rect(cornerRadius: style.search.cornerRadius).stroke(lineWidth: 1)
                    )
            }
            .overlay(
                style.search.outerStrokeStyle(isActive: !searchTerm.isEmpty),
                in: .rect(cornerRadius: style.search.cornerRadius).stroke(lineWidth: 2)
            )
            .defaultShadow(color: .blue.opacity(0.2), isActive: !searchTerm.isEmpty)
        }
    }
    
    private var searchScopeSegment: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Button {
                        searchScope = scope
                    } label: {
                        Text(scope.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(style.search.segment.textColor(isActive: searchScope == scope))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
            }
            .background(
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: style.search.segment.cornerRadius)
                        .fill(style.search.segment.activeStyle)
                        .frame(width: proxy.size.width/2)
                        .offset(x: searchScope == .contacts ? 0 : proxy.size.width/2)
                }
            )
            .background {
                RoundedRectangle(cornerRadius: style.search.segment.cornerRadius)
                    .fill(style.search.segment.backgroundColor)
                    .overlay(
                        style.search.segment.strokeColor,
                        in: .rect(cornerRadius: style.search.segment.cornerRadius).stroke(lineWidth: 1)
                    )
            }
            .defaultShadow(color: .blue.opacity(0.2))
        }
        .padding(.bottom, 16)
    }
    
    private var emptySearchState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(style.search.emptyState.iconColor)
            
            VStack(spacing: 8) {
                Text("Search \(searchScope.rawValue)")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(style.search.emptyState.titleColor)
                
                Text("Type to search for \(searchScope == .contacts ? "contact names" : "message content")")
                    .font(.subheadline)
                    .foregroundColor(style.search.emptyState.subtitleColor)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
    }
    
    private var searchResultsList: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(contactsResult.total) \(searchScope.rawValue.lowercased()) found.")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            if !isLoading, contactsResult.contacts.isEmpty {
                noResultsView
            } else {
                contactList
            }
        }
    }
    
    private var contactList: some View {
        List {
            ForEach(contactsResult.contacts) { contact in
                ContactRow(
                    contact: contact,
                    isPressed: selectedContactID == contact.id,
                    loadAvatar: {
                        guard let url = contact.responder.avatarURL,
                              let data = await loadAvatarData(url) else {
                            return nil
                        }
                        
                        return UIImage(data: data)
                    }
                )
                .onTapGesture {
                    selectedContactID = contact.id
                    rowTapped(contact)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { selectedContactID = nil }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .onAppear {
                    if contactsResult.contacts.last == contact { searchMoreContacts() }
                }
            }
            .listRowInsets(.init(top: 5, leading: 18, bottom: 5, trailing: 18))
        }
        .listStyle(.plain)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(
                systemName: searchScope == .contacts ?
                    "person.crop.circle.badge.questionmark" :
                    "questionmark.bubble"
            )
            .font(.system(size: 60))
            .foregroundColor(style.search.noResults.iconColor)
            
            VStack(spacing: 8) {
                Text("No \(searchScope.rawValue.lowercased()) found")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(style.search.noResults.titleColor)
                
                Text("Try searching for a different \(searchScope == .contacts ? "name" : "message")")
                    .font(.subheadline)
                    .foregroundColor(style.search.noResults.subtitleColor)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationView {
        SearchContentView(
            contactsResult: SearchContactsResult(
                contacts: [
                    Contact(
                        id: 0,
                        responder: User(
                            id: 0,
                            name: "Harry",
                            email: "harry@email.com",
                            avatarURL: nil,
                            createdAt: .now
                        ),
                        blockedByUserID: nil,
                        unreadMessageCount: 0,
                        createdAt: .now,
                        lastUpdate: .now - 3,
                        lastMessage: nil
                    ),
                    Contact(
                        id: 1,
                        responder: User(
                            id: 1,
                            name: "Jo",
                            email: "jo@email.com",
                            avatarURL: nil,
                            createdAt: .now
                        ),
                        blockedByUserID: nil,
                        unreadMessageCount: 100,
                        createdAt: .now,
                        lastUpdate: .distantPast,
                        lastMessage: MessageWithMetadata(
                            message: .init(id: 1, text: "Last message text", senderID: 1, isRead: false, createdAt: .now, editedAt: nil, deletedAt: nil),
                            metadata: .init(previousID: nil)
                        )
                    )
                ],
                total: 2
            ),
            searchTerm: .constant("s"),
            isLoading: false,
            searchContacts: {},
            searchMoreContacts: {},
            loadAvatarData: { _ in nil },
            rowTapped: { _ in }
        )
    }
    .environment(ViewStyleManager())
    .preferredColorScheme(.light)
}
