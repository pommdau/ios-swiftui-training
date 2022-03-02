//
//  Repo.swift
//  GitHubClient
//
//  Created by HIROKI IKEUCHI on 2022/03/02.
//

import Foundation

struct Repo: Identifiable {
    var id: Int
    var name: String
    var owner: User
    var description: String
    var stargazersCount: Int
}
