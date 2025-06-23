//
//  SearchViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/06/2025.
//

import Foundation

struct SearchContactsResult: Equatable {
    let contacts: [Contact]
    let total: Int
}

@MainActor @Observable
final class SearchViewModel {
    private(set) var contactsResult = SearchContactsResult(contacts: [], total: 0)
    var searchTerm = ""
    var generalError: String?
    private(set) var isLoading = false
    
    private var searchContactsTask: Task<Void, Never>?
    private var searchMoreContactsTask: Task<Void, Never>?
    private var hasMoreContacts = false
    
    private let searchContactsUseCase: SearchContacts
    private let loadImageData: LoadImageData
    
    init(searchContacts: SearchContacts, loadImageData: LoadImageData) {
        self.searchContactsUseCase = searchContacts
        self.loadImageData = loadImageData
    }
    
    func searchContacts() {
        guard !searchTerm.isEmpty else { return }
        
        searchContactsTask?.cancel()
        searchContactsTask = Task {
            defer { isLoading = false }
            
            try? await Task.sleep(for: .seconds(0.5)) // Debounce
            guard !searchTerm.isEmpty, !Task.isCancelled else { return }
            
            isLoading = true
            do throws(UseCaseError) {
                let param = SearchContactsParams(searchTerm: searchTerm)
                let searched = try await searchContactsUseCase.search(by: param)
                if !Task.isCancelled {
                    contactsResult = SearchContactsResult(contacts: searched.contacts, total: searched.total)
                    hasMoreContacts = searched.hasMore
                }
            } catch {
                generalError = error.toGeneralErrorMessage()
            }
        }
    }
    
    func searchMoreContacts() {
        guard hasMoreContacts, !searchTerm.isEmpty, searchMoreContactsTask == nil else { return }
        
        searchMoreContactsTask = Task {
            defer { searchMoreContactsTask = nil }
            
            do throws(UseCaseError) {
                let param = SearchContactsParams(
                    searchTerm: searchTerm,
                    before: contactsResult.contacts.last?.lastUpdate
                )
                let searched = try await searchContactsUseCase.search(by: param)
                contactsResult = SearchContactsResult(
                    contacts: contactsResult.contacts + searched.contacts,
                    total: searched.total
                )
                hasMoreContacts = searched.hasMore
            } catch {
                generalError = error.toGeneralErrorMessage()
            }
        }
    }
    
    func loadAvatarData(url: URL) async -> Data? {
        try? await loadImageData.load(for: url)
    }
}
