//
//  DemonicGenreRandomizerTests.swift
//  DemonicGenreRandomizerTests
//
//  Created by David Martens on 28.10.26.
//

import Testing
@testable import DemonicGenreRandomizer

struct DemonicGenreRandomizerTests {

    @Test func libraryHasAtLeastSixtyUniqueGenres() {
        let all = GenreLibrary.all
        #expect(all.count >= 60)
        #expect(Set(all.map { $0.lowercased() }).count == all.count)
    }

    @Test(arguments: GenreCount.allCases)
    func generatesExactCountOfDistinctGenres(count: GenreCount) {
        let randomizer = GenreRandomizer()
        for _ in 0..<500 {
            let genres = randomizer.generate(count: count.rawValue)
            #expect(genres.count == count.rawValue)
            #expect(Set(genres).count == count.rawValue)
            #expect(genres.allSatisfy(GenreLibrary.all.contains))
        }
    }

    @Test func neverRepeatsPreviousCombination() {
        let randomizer = GenreRandomizer(genres: ["A", "B", "C", "D"])
        var previous = randomizer.generate(count: 3)
        for _ in 0..<500 {
            let next = randomizer.generate(count: 3, avoiding: previous)
            #expect(Set(next) != Set(previous))
            previous = next
        }
    }

    @Test func returnsOnlyPossibleCombinationWhenNoAlternativeExists() {
        let randomizer = GenreRandomizer(genres: ["A", "B", "C"])
        let genres = randomizer.generate(count: 3, avoiding: ["C", "B", "A"])
        #expect(Set(genres) == ["A", "B", "C"])
    }

    @Test func everyGenreIsPickedRoughlyEqually() {
        let pool = (1...10).map { "Genre \($0)" }
        let randomizer = GenreRandomizer(genres: pool)
        var counts: [String: Int] = [:]
        let runs = 20_000
        for _ in 0..<runs {
            for genre in randomizer.generate(count: 3) {
                counts[genre, default: 0] += 1
            }
        }
        let expected = Double(runs * 3) / Double(pool.count)
        for genre in pool {
            let deviation = abs(Double(counts[genre, default: 0]) - expected) / expected
            #expect(deviation < 0.05)
        }
    }

    @Test func promptTextIsPlainCommaSeparatedList() {
        let text = GenreRandomizer.promptText(for: ["Industrial Metal", "Darkwave", "Epic Cinematic"])
        #expect(text == "Industrial Metal, Darkwave, Epic Cinematic")
    }
}
