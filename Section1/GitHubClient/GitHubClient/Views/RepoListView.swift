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
            Group {
            if reposLoader.error != nil {
                // Error View
                VStack {
                    Group {
                        Image("GitHubMark")
                        Text("Failed to load repositories")
                            .padding(.top, 4)
                    }
                    .foregroundColor(.black)
                    .opacity(0.4)
                    
                    Button(
                        action: {
                            reposLoader.call()
                        }, label: {
                            Text("Retry")
                                .fontWeight(.bold)
                        }
                    )
                        .padding(.top, 8)
                }
            } else {
                if reposLoader.isLoading {
                    ProgressView("loading...")
                } else {
                    if reposLoader.repos.isEmpty {
                        Text("No repositories")
                            .fontWeight(.bold)
                    } else {
                        List(reposLoader.repos) { repo in
                            NavigationLink(
                                destination: RepoDetailView(repo: repo)) {
                                    RepoRow(repo: repo)
                                }
                        }
                    }
                }
            }
            }
            .navigationTitle("Repositories")
        }
        .onAppear {
            reposLoader.call()
        }
    }
    
}

// MARK: - ReposLoader

class ReposLoader: ObservableObject {
    
    @Published private(set) var repos = [Repo]()
    @Published private(set) var error: Error? = nil
    @Published private(set) var isLoading: Bool = false
    
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
                //                guard
                //                    let httpResponse = element.response as? HTTPURLResponse,
                //                    httpResponse.statusCode == 200 else {
                //                        throw URLError(.badServerResponse)
                //                    }
                //                return element.data
                throw URLError(.badServerResponse)
            }
            .decode(type: [Repo].self, decoder: JSONDecoder())
        
        reposPublisher
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.isLoading = true
            })
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error: \(error)")
                    self?.error = error
                }
                self?.isLoading = false
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
