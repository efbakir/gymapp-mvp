//
//  OnboardingProgramImportView.swift
//  Unit
//
//  Screen 4 — Parse a pasted plan into structured day data, then continue
//  straight to the exercises step where editing and reordering live.
//

import SwiftUI
import Vision

/// Single source of truth for paste-mode placeholder copy.
private enum ProgramPasteFormatGuide {
    /// Combined intro (replaces separate subtitle + footer under the editor). Full rules stay in the format sheet.
    static let subtitle =
        "Paste from Notes, chat, or a document. One day per line, then exercises (kg, lb, or BW). "
        + "Include at least one day and one exercise. Lines starting with // are skipped."

    /// Placeholder is examples only — short, by design (long rules live in the format examples sheet).
    static let placeholderExamples = [
        "Push",
        "Bench press 4x8 60kg",
        "Incline DB press 3x10 22kg",
        "",
        "Pull",
        "Deadlift 3x5 100kg",
        "Pull-up 4x8 BW",
    ].joined(separator: "\n")
}

struct OnboardingProgramImportView: View {
    @Environment(OnboardingViewModel.self) private var vm

    var progressStep: Int
    var progressTotal: Int
    var onContinue: () -> Void

    @State private var pastedText = ""
    @State private var isParsing = false
    @State private var errorMessage: String?
    @State private var showingFormatExamples = false

    private var canParse: Bool {
        !pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        OnboardingShell(
            title: "Paste your program",
            subtitle: ProgramPasteFormatGuide.subtitle,
            ctaLabel: parseLabel,
            ctaEnabled: canParse && !isParsing,
            progressStep: progressStep,
            progressTotal: progressTotal,
            onContinue: { Task { await parseProgram() } }
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                AppTextEditor(
                    text: $pastedText,
                    placeholder: ProgramPasteFormatGuide.placeholderExamples
                )
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()

                AppGhostButton("Show format examples") {
                    showingFormatExamples = true
                }

                if isParsing {
                    HStack(spacing: AppSpacing.sm) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Reading exercises, reps, and weights.")
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingFormatExamples) {
            FormatExamplesSheet()
                .presentationDetents([.medium, .large])
                .appBottomSheetChrome()
        }
        .alert("Couldn't read that program", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var parseLabel: String {
        isParsing ? "Reading…" : "Read program"
    }

    @MainActor
    private func parseProgram() async {
        guard !isParsing else { return }
        isParsing = true
        defer { isParsing = false }

        let parsed = ProgramImportParser.parse(pastedText)
        guard !parsed.isEmpty else {
            errorMessage = "Couldn't find exercises. Put each day on its own line, then list each exercise below it."
            return
        }
        vm.applyImportedProgram(parsed)
        onContinue()
    }
}

// MARK: - Format Examples Sheet

private struct FormatExamplesSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack {
                Text("Format examples")
                    .font(AppFont.largeTitle.font)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    AppIcon.close.image(size: 14, weight: .semibold)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                ruleSection(
                    title: "Day names",
                    body: "One day name per line: Push, Pull, Legs, Upper, Lower, Full body, Arms, Chest, Back, Shoulders, Day 1–6, or a weekday."
                )

                ruleSection(
                    title: "Exercises",
                    body: "Below each day, one exercise per line: name, then setsxreps, then weight. Example: Bench press 4x8 60kg."
                )

                ruleSection(
                    title: "Weight units",
                    body: "Use kg, lb, or BW for bodyweight. Lines starting with // are skipped."
                )
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.xl)
    }

    @ViewBuilder
    private func ruleSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppColor.textPrimary)
            Text(body)
                .font(AppFont.body.font)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

// MARK: - Parser

enum ProgramImportParser {
    private static let knownDayNames = [
        "push", "pull", "legs", "upper", "lower", "full body", "arms",
        "chest", "back", "shoulders", "day 1", "day 2", "day 3", "day 4", "day 5", "day 6",
        "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"
    ]

    static func extractText(from data: Data) async -> String {
        guard let image = UIImage(data: data),
              let cgImage = image.cgImage else {
            return ""
        }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                let text = (request.results as? [VNRecognizedTextObservation])?
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n") ?? ""
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage)
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: "")
            }
        }
    }

    static func parse(_ rawText: String) -> [ImportedProgramDay] {
        let lines = rawText
            .components(separatedBy: .newlines)
            .map { sanitizeLine($0) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else { return [] }

        var days: [ImportedProgramDay] = []
        var currentDayName = "Workout 1"
        var currentExercises: [ImportedProgramExercise] = []

        func flushCurrentDay() {
            guard !currentExercises.isEmpty else { return }
            days.append(ImportedProgramDay(name: currentDayName, exercises: currentExercises))
            currentExercises = []
        }

        for line in lines {
            if line.hasPrefix("//") {
                continue
            }

            if let heading = parsedDayHeading(from: line) {
                flushCurrentDay()
                currentDayName = heading
                continue
            }

            if let exercise = parsedExercise(from: line) {
                currentExercises.append(exercise)
            }
        }

        flushCurrentDay()

        if days.isEmpty {
            let exercises = lines.compactMap(parsedExercise(from:))
            if !exercises.isEmpty {
                days = [ImportedProgramDay(name: "Workout 1", exercises: exercises)]
            }
        }

        return Array(days.prefix(6))
    }

    private static func sanitizeLine(_ line: String) -> String {
        line
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "•", with: " ")
            .replacingOccurrences(of: "·", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func parsedDayHeading(from line: String) -> String? {
        let lowered = line.lowercased()
        guard knownDayNames.contains(where: { lowered == $0 || lowered.hasPrefix("\($0):") || lowered.hasPrefix("\($0) ") }) else {
            return nil
        }
        return titleCaseHeading(line)
    }

    private static func titleCaseHeading(_ line: String) -> String {
        line
            .replacingOccurrences(of: ":", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }

    private static func parsedExercise(from line: String) -> ImportedProgramExercise? {
        var remaining = line
        guard remaining.rangeOfCharacter(from: .letters) != nil else { return nil }

        let setsRepsPattern = #"(?i)\b(\d{1,2})\s*[x×]\s*(\d{1,3})\b"#
        let setsPattern = #"(?i)\bsets?\s*[:\-]?\s*(\d{1,2})\b"#
        let repsPattern = #"(?i)\breps?\s*[:\-]?\s*(\d{1,3})\b"#
        let weightPattern = #"(?i)\b(\d{1,3}(?:[.,]\d+)?)\s*(kg|kgs|lb|lbs)\b"#
        let bodyweightPattern = #"(?i)\b(bodyweight|bw)\b"#

        var sets: Int?
        var reps: Int?
        var weightKg: Double?

        if let match = firstMatch(in: remaining, pattern: setsRepsPattern),
           let setValue = Int(match[1]), let repValue = Int(match[2]) {
            sets = setValue
            reps = repValue
            remaining = remaining.replacingOccurrences(of: match[0], with: " ")
        }

        if sets == nil, let match = firstMatch(in: remaining, pattern: setsPattern), let setValue = Int(match[1]) {
            sets = setValue
            remaining = remaining.replacingOccurrences(of: match[0], with: " ")
        }

        if reps == nil, let match = firstMatch(in: remaining, pattern: repsPattern), let repValue = Int(match[1]) {
            reps = repValue
            remaining = remaining.replacingOccurrences(of: match[0], with: " ")
        }

        if let match = firstMatch(in: remaining, pattern: weightPattern) {
            let numericString = match[1].replacingOccurrences(of: ",", with: ".")
            let unit = match[2].lowercased()
            if let value = Double(numericString) {
                weightKg = unit.hasPrefix("lb") ? value / 2.20462 : value
            }
            remaining = remaining.replacingOccurrences(of: match[0], with: " ")
        } else if firstMatch(in: remaining, pattern: bodyweightPattern) != nil {
            remaining = replacingMatches(in: remaining, pattern: bodyweightPattern, with: " ")
        }

        remaining = replacingMatches(in: remaining, pattern: #"(?i)\b\d+\b"#, with: " ")
        remaining = remaining.replacingOccurrences(of: "-", with: " ")
        remaining = remaining.replacingOccurrences(of: "/", with: " ")
        remaining = remaining.replacingOccurrences(of: "(", with: " ")
        remaining = remaining.replacingOccurrences(of: ")", with: " ")
        remaining = remaining
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard remaining.rangeOfCharacter(from: .letters) != nil else { return nil }
        let cleanedName = remaining.capitalized

        return ImportedProgramExercise(
            name: cleanedName,
            sets: sets,
            reps: reps,
            weightKg: weightKg
        )
    }

    private static func firstMatch(in text: String, pattern: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range) else { return nil }
        return (0..<match.numberOfRanges).compactMap { index in
            guard let range = Range(match.range(at: index), in: text) else { return nil }
            return String(text[range])
        }
    }

    private static func replacingMatches(in text: String, pattern: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
        let range = NSRange(text.startIndex..., in: text)
        return regex.stringByReplacingMatches(in: text, range: range, withTemplate: replacement)
    }
}

#Preview {
    NavigationStack {
        OnboardingProgramImportView(progressStep: 2, progressTotal: 6) { }
            .environment(OnboardingViewModel())
    }
}
