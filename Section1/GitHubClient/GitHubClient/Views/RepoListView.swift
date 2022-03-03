//
//  ContentView.swift
//  GitHubClient
//
//  Created by HIROKI IKEUCHI on 2022/03/02.
//

import SwiftUI
import Combine

struct RepoListView: View {
    
    // MARK: - Properties
    
    @StateObject private var reposLoader = ReposLoader()
    
    // MARK: - Views
    
    var body: some View {
        NavigationView {
            if reposLoader.repos.isEmpty {
                ProgressView("loading...")
            } else {
                List(reposLoader.repos) { repo in
                    NavigationLink(
                        destination: RepoDetailView(repo: repo)) {
                            RepoRow(repo: repo)
                        }
                }
                .navigationTitle("Repositories")
            }
        }
        .onAppear {
            reposLoader.call()
        }
    }
        
}

// MARK: - ReposLoader

class ReposLoader: ObservableObject {
    
    @Published private(set) var repos = [Repo]()
    
    private var cancellables = Set<AnyCancellable>()
    
    func call() {
        let reposPublisher = Future<[Repo], Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                promise(.success([
                    .mock1, .mock2, .mock3, .mock4, .mock5
                ]))
            }
        }
        reposPublisher
            .sink(receiveCompletion: { completion in
                print("Finished: \(completion)")
            }, receiveValue: { [weak self] repos in
                self?.repos = repos
            }
            ).store(in: &cancellables)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}
