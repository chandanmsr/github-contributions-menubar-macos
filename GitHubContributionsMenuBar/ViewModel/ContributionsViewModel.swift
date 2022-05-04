//
//  ContributionsViewModel.swift
//  GitHubContributionsMenuBar
//
//  Created by 宮本大新 on 2022/05/05.
//

import Combine
import Foundation

final class ContributionsViewModel: ObservableObject {

    struct Contributions {
        var levels: [[GitHub.Contribution.Level]] = []
        var count: Int = .zero
    }

    let username: String
    @Published private(set) var contributions: Contributions = .init()

    private let queue = DispatchQueue(label: "com.andergoig.GitHubContributions.network")

    init(username: String) {
        self.username = username
    }

    func getContributions(username: String) {
        guard contributions.levels.isEmpty else { return }

        GitHub.getContributions(for: username, queue: queue)
            .subscribe(on: queue)
            .replaceError(with: [])
            .map(Self.mapContributions)
            .receive(on: DispatchQueue.main)
            .assign(to: &$contributions)
    }

    private static func mapContributions(_ contributions: [GitHub.Contribution]) -> Contributions {
        guard let lastDate = contributions.last?.date else { return .init() }
        let tilesCount = 7 * 20 - (7 - Calendar.current.component(.weekday, from: lastDate))
        let levels = contributions.suffix(tilesCount).map(\.level).chunked(into: 7)
        let count = contributions.reduce(0) { $0 + $1.count }
        return Contributions(levels: levels, count: count)
    }
}
