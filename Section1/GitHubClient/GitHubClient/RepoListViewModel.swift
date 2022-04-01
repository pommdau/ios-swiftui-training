//
//  RepoListViewModel.swift
//  GitHubClient
//
//  Created by HIROKI IKEUCHI on 2022/03/04.
//

import Foundation
import Combine

class RepoListViewModel: ObservableObject {
    @Published private(set) var repos: Stateful<[Repo]> = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    private let repoRepository: RepoRepository
    
    init(repoRepository: RepoRepository = RepoDataRepository()) {
        self.repoRepository = repoRepository
    }
    
    func onAppear() {
        loadRepos()
    }
    
    func onRetryButtonTapped() {
        loadRepos()
    }
    
    private func loadRepos() {
        repoRepository.fetchRepos()
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.repos = .loading
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Error: \(error)")
                    self?.repos = .failed(error)
                case .finished: print("Finished")
                }
            }, receiveValue: { [weak self] repos in
                self?.repos = .loaded(repos)
            }
            ).store(in: &cancellables)
    }
    
    
}
