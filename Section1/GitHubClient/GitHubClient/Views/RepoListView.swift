//
//  ContentView.swift
//  GitHubClient
//
//  Created by HIROKI IKEUCHI on 2022/03/02.
//

import SwiftUI

struct RepoListView: View {
    
    // MARK: - Properties
    
    @State private var mockRepos: [Repo] = []
    
    // MARK: - Views
    
    var body: some View {
        NavigationView {
            List(mockRepos) { repo in
                NavigationLink(
                    destination: RepoDetailView(repo: repo)) {
                        RepoRow(repo: repo)
                    }
            }
            .navigationTitle("Repositories")
            .onAppear {
                loadRepos()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func loadRepos() {
        // 1秒後にモックデータを読み込む
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            mockRepos = [
                .mock1, .mock2, .mock3, .mock4, .mock5
            ]
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}
