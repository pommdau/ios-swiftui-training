//
//  ContentView.swift
//  GitHubClient
//
//  Created by HIROKI IKEUCHI on 2022/03/02.
//

import SwiftUI

struct RepoListView: View {
    
    private let mockRepos: [Repo] = [
        .mock1, .mock2, .mock3, .mock4, .mock5
    ]
    
    var body: some View {
        List(mockRepos) { repo in
            RepoRow(repo: repo)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}
