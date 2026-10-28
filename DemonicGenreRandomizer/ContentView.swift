//
//  ContentView.swift
//  DemonicGenreRandomizer
//
//  Created by David Martens on 28.10.26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("genreCount") private var genreCount: GenreCount = .three

    @State private var genres: [String] = []
    @State private var generation = 0
    @State private var isCopied = false
    @State private var copyCount = 0
    @State private var copyResetTask: Task<Void, Never>?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let randomizer = GenreRandomizer()

    private var promptText: String {
        GenreRandomizer.promptText(for: genres)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header
                countPicker
                resultSection
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Theme.background.ignoresSafeArea())
        .tint(Theme.crimson)
        .sensoryFeedback(.impact(weight: .light), trigger: generation)
        .sensoryFeedback(.success, trigger: copyCount)
        .onChange(of: genreCount) {
            if !genres.isEmpty {
                generate()
            }
        }
    }

    // MARK: - Abschnitte

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .font(.largeTitle)
                .foregroundStyle(Theme.accentGradient)
                .shadow(color: Theme.crimson.opacity(0.7), radius: 14)
                .accessibilityHidden(true)

            Text("Demonic Prompt Randomizer")
                .font(.largeTitle.weight(.heavy))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .accessibilityAddTraits(.isHeader)

            Text("Genre-Mixe als Inspiration für deine Musik-Prompts")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(.top, 8)
    }

    private var countPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Anzahl der Genres", systemImage: "number")
                .font(.headline)
                .foregroundStyle(.white)

            Picker("Anzahl der Genres", selection: $genreCount) {
                ForEach(GenreCount.allCases) { count in
                    Text("\(count.rawValue)")
                        .accessibilityLabel("\(count.rawValue) Genres")
                        .tag(count)
                }
            }
            .pickerStyle(.segmented)
        }
        .cardStyle()
    }

    @ViewBuilder
    private var resultSection: some View {
        if genres.isEmpty {
            VStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(Theme.accentGradient)
                    .accessibilityHidden(true)
                Text("Wähle die Anzahl und generiere deinen Genre-Mix.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .cardStyle()
            .transition(.opacity)
        } else {
            VStack(alignment: .leading, spacing: 16) {
                Label("Dein Genre-Mix", systemImage: "music.note.list")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: 10) {
                    ForEach(Array(genres.enumerated()), id: \.element) { index, genre in
                        GenreCard(position: index + 1, genre: genre)
                            .id("\(generation)-\(genre)")
                            .transition(
                                reduceMotion
                                    ? .opacity
                                    : .asymmetric(
                                        insertion: .scale(scale: 0.92).combined(with: .opacity),
                                        removal: .opacity
                                    )
                            )
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Zusammenstellung")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.secondaryText)
                    Text(promptText)
                        .font(.body.monospaced())
                        .foregroundStyle(.white)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Theme.violet.opacity(0.35), lineWidth: 1)
                        )
                }
                .accessibilityElement(children: .combine)
            }
            .cardStyle()
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: generate) {
                Label("Generieren", systemImage: "shuffle")
                    .symbolEffect(.bounce, value: generation)
            }
            .buttonStyle(DemonicButtonStyle(prominent: true))
            .accessibilityHint("Erzeugt eine neue zufällige Genre-Kombination")

            Button(action: copy) {
                Label(
                    isCopied ? "Kopiert!" : "Kopieren",
                    systemImage: isCopied ? "checkmark" : "doc.on.doc"
                )
                .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(DemonicButtonStyle(prominent: false))
            .disabled(genres.isEmpty)
            .accessibilityHint("Kopiert die Genre-Liste in die Zwischenablage")
        }
    }

    // MARK: - Aktionen

    private func generate() {
        let newGenres = randomizer.generate(count: genreCount.rawValue, avoiding: genres)
        let animation: Animation = reduceMotion
            ? .easeInOut(duration: 0.2)
            : .spring(response: 0.45, dampingFraction: 0.78)
        withAnimation(animation) {
            genres = newGenres
            generation += 1
            isCopied = false
        }
        AccessibilityNotification.Announcement(
            "Neuer Mix: \(GenreRandomizer.promptText(for: newGenres))"
        ).post()
    }

    private func copy() {
        guard !genres.isEmpty else { return }
        UIPasteboard.general.string = promptText
        copyCount += 1
        withAnimation(.easeInOut(duration: 0.2)) { isCopied = true }
        AccessibilityNotification.Announcement("Kopiert!").post()

        copyResetTask?.cancel()
        copyResetTask = Task {
            try? await Task.sleep(for: .seconds(1.6))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.2)) { isCopied = false }
        }
    }
}

// MARK: - Bausteine

private struct GenreCard: View {
    let position: Int
    let genre: String

    @ScaledMetric(relativeTo: .headline) private var badgeSize = 32

    var body: some View {
        HStack(spacing: 14) {
            Text("\(position)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(.white)
                .frame(minWidth: badgeSize, minHeight: badgeSize)
                .background(Theme.accentGradient, in: Circle())
                .shadow(color: Theme.crimson.opacity(0.6), radius: 8)

            Text(genre)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Theme.deepRed.opacity(0.55), Theme.violet.opacity(0.22)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Theme.accentGradient.opacity(0.6), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Genre \(position): \(genre)")
    }
}

private struct DemonicButtonStyle: ButtonStyle {
    let prominent: Bool

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(prominent ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.surface))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        prominent ? Color.white.opacity(0.18) : Theme.violet.opacity(0.55),
                        lineWidth: 1
                    )
            }
            .shadow(color: prominent && isEnabled ? Theme.crimson.opacity(0.55) : .clear, radius: 16, y: 4)
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Theme.crimson.opacity(0.45), Theme.violet.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Theme.crimson.opacity(0.15), radius: 20)
    }
}

private extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Farben

enum Theme {
    static let crimson = Color(red: 0.80, green: 0.09, blue: 0.18)
    static let deepRed = Color(red: 0.42, green: 0.02, blue: 0.08)
    static let violet = Color(red: 0.62, green: 0.22, blue: 0.88)
    static let surface = Color.white.opacity(0.06)
    static let secondaryText = Color.white.opacity(0.7)

    static let accentGradient = LinearGradient(
        colors: [crimson, violet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static var background: some View {
        ZStack {
            Color(red: 0.03, green: 0.012, blue: 0.035)
            RadialGradient(
                colors: [deepRed.opacity(0.55), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 520
            )
            RadialGradient(
                colors: [violet.opacity(0.18), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 460
            )
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
