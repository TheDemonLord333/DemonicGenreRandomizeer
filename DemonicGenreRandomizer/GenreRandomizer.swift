//
//  GenreRandomizer.swift
//  DemonicGenreRandomizer
//

import Foundation

/// Die wählbaren Genre-Anzahlen.
nonisolated enum GenreCount: Int, CaseIterable, Identifiable {
    case three = 3
    case four = 4
    case five = 5

    var id: Int { rawValue }
}

/// Zieht zufällige, doppelfreie Genre-Kombinationen aus einer Sammlung.
nonisolated struct GenreRandomizer {
    let genres: [String]

    init(genres: [String] = GenreLibrary.all) {
        self.genres = genres
    }

    /// Erzeugt `count` unterschiedliche Genres. Jedes Genre hat dieselbe Wahrscheinlichkeit.
    /// Eine Kombination mit denselben Genres wie `previous` (unabhängig von der Reihenfolge)
    /// wird verworfen und neu gezogen, solange überhaupt eine andere Kombination möglich ist.
    func generate<R: RandomNumberGenerator>(
        count: Int,
        avoiding previous: [String] = [],
        using generator: inout R
    ) -> [String] {
        let count = min(max(count, 0), genres.count)
        let previousSet = Set(previous)
        let canDiffer = count < genres.count || previousSet != Set(genres)

        var result: [String]
        repeat {
            result = Array(genres.shuffled(using: &generator).prefix(count))
        } while canDiffer && !previousSet.isEmpty && Set(result) == previousSet
        return result
    }

    func generate(count: Int, avoiding previous: [String] = []) -> [String] {
        var generator = SystemRandomNumberGenerator()
        return generate(count: count, avoiding: previous, using: &generator)
    }

    /// Kommagetrennte Liste, z. B. „Industrial Metal, Darkwave, Epic Cinematic“.
    static func promptText(for genres: [String]) -> String {
        genres.joined(separator: ", ")
    }
}
