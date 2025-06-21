//
//  SearchViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/06/2025.
//

import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published private(set) var contacts = [Contact]()
    @Published var searchTerm = ""
    @Published private(set) var generalError: String?
    var isLoading: Bool { searchContactsTask ?? searchMoreContactsTask != nil }
    
    @Published private var searchContactsTask: Task<Void, Never>?
    @Published private var searchMoreContactsTask: Task<Void, Never>?
    private var hasMoreContacts = false
    
    private let searchContactsUseCase: SearchContacts
    
    init(searchContacts: SearchContacts) {
        self.searchContactsUseCase = searchContacts
    }
    
    func searchContacts() {
        guard !searchTerm.isEmpty, searchContactsTask == nil else { return }
        
        searchContactsTask = Task {
            defer { searchContactsTask = nil }
            
            try? await Task.sleep(for: .seconds(0.3)) // Debounce
            guard !searchTerm.isEmpty else { return }
            
            do throws(UseCaseError) {
                let param = SearchContactsParams(searchTerm: searchTerm)
                let searched = try await searchContactsUseCase.search(by: param)
                contacts = searched.contacts
                hasMoreContacts = searched.hasMore
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
                let param = SearchContactsParams(searchTerm: searchTerm, before: contacts.last?.lastUpdate)
                let searched = try await searchContactsUseCase.search(by: param)
                contacts += searched.contacts
                hasMoreContacts = searched.hasMore
            } catch {
                generalError = error.toGeneralErrorMessage()
            }
        }
    }
}
