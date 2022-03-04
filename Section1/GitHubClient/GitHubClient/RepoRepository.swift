//
//  RepoRepository.swift
//  GitHubClient
//
//  Created by HIROKI IKEUCHI on 2022/03/04.
//

import Foundation
import Combine

struct RepoRepository {
    func fetchRepos() -> AnyPublisher<[Repo], Error> {
        RepoAPIClient().getRepos()
    }
}
