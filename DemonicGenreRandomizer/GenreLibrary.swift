//
//  GenreLibrary.swift
//  DemonicGenreRandomizer
//

import Foundation

/// Lokale Genre-Sammlung. Neue Genres einfach in der passenden Kategorie ergänzen –
/// doppelte Einträge werden beim Zusammenführen automatisch entfernt.
nonisolated enum GenreLibrary {
    static let metal = [
        "Industrial Metal",
        "Symphonic Metal",
        "Deathcore",
        "Black Metal",
        "Death Metal",
        "Melodic Death Metal",
        "Doom Metal",
        "Thrash Metal",
        "Nu Metal",
        "Metalcore",
        "Gothic Metal",
        "Power Metal",
        "Djent",
        "Sludge Metal",
        "Folk Metal",
        "Post-Metal",
    ]

    static let rock = [
        "Gothic Rock",
        "Post-Punk",
        "Hard Rock",
        "Alternative Rock",
        "Grunge",
        "Psychedelic Rock",
        "Stoner Rock",
        "Shoegaze",
        "Post-Rock",
        "Punk Rock",
        "Industrial Rock",
        "Progressive Rock",
    ]

    static let electronic = [
        "Darkwave",
        "Synthwave",
        "Darksynth",
        "Witch House",
        "Drum and Bass",
        "Dubstep",
        "Techno",
        "Industrial Techno",
        "Trance",
        "Hardstyle",
        "EBM",
        "Aggrotech",
        "Coldwave",
        "Deep House",
        "Breakbeat",
        "IDM",
        "Trip-Hop",
        "Future Bass",
    ]

    static let hipHop = [
        "Trap",
        "Phonk",
        "Drill",
        "Boom Bap",
        "Horrorcore",
        "Cloud Rap",
        "Lo-Fi Hip-Hop",
        "Grime",
        "Memphis Rap",
    ]

    static let pop = [
        "Dark Pop",
        "Synth-Pop",
        "Electropop",
        "Dream Pop",
        "Hyperpop",
        "Indie Pop",
        "Art Pop",
    ]

    static let classical = [
        "Orchestral",
        "Neoclassical",
        "Baroque",
        "Choral",
        "Opera",
        "Chamber Music",
        "Gregorian Chant",
        "Minimalist Classical",
    ]

    static let folk = [
        "Dark Folk",
        "Neofolk",
        "Nordic Folk",
        "Celtic Folk",
        "Medieval Folk",
        "Americana",
        "Bluegrass",
    ]

    static let jazzAndBlues = [
        "Jazz",
        "Blues",
        "Dark Jazz",
        "Jazz Fusion",
        "Bebop",
        "Swing",
        "Delta Blues",
        "Soul",
        "Funk",
    ]

    static let atmospheric = [
        "Dark Ambient",
        "Ambient",
        "Epic Cinematic",
        "Drone",
        "Ritual Ambient",
        "Dungeon Synth",
        "Space Ambient",
        "Horror Score",
    ]

    /// Alle Genres ohne Duplikate (Groß-/Kleinschreibung wird ignoriert), in stabiler Reihenfolge.
    static let all: [String] = {
        var seen = Set<String>()
        return (metal + rock + electronic + hipHop + pop + classical + folk + jazzAndBlues + atmospheric)
            .filter { seen.insert($0.lowercased()).inserted }
    }()
}
