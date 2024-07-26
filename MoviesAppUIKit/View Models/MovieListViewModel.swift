//
//  MovieListViewModel.swift
//  MoviesAppUIKit
//
//  Created by Sergiu on 26.07.2024.
//

import Foundation
import Combine

class MovieListViewModel {
    @Published private(set) var movies: [Movie] = []
    
    let httpClient: HTTPClient
    var cancellable: Set<AnyCancellable> = []
    @Published var isLodingCompleted: Bool = false
    private var searchSubject = CurrentValueSubject<String, Never>("")
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
        setupSearchSubject()
    }
    
    private func setupSearchSubject() {
        searchSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] searchTest in
                self?.loadMovies(search: searchTest)
            }
            .store(in: &cancellable)
    }
    
    func setSearchText(_ searchText: String) {
        searchSubject.send(searchText)
    }
    
    func loadMovies(search: String) {
        httpClient.fetchMovies(search: search)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    defer {
                        self?.isLodingCompleted = true
                    }
                    print("Update UI")
                case .failure(let error):
                    print("Error: ", error.localizedDescription)
                }
            } receiveValue: { [weak self] movies in
                self?.movies = movies
            }
            .store(in: &cancellable)
    }
}
