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
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "application/vnd.github.v3+json"
        ]
        
        let reposPublisher = URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap() { element -> Data in
                guard
                    let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                return element.data
            }
            .decode(type: [Repo].self, decoder: JSONDecoder())
                
        reposPublisher
            .receive(on: DispatchQueue.main)
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
