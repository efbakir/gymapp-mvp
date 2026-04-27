//
//  OnboardingProgramImportView.swift
//  Unit
//
//  Screen 4 — Parse a pasted plan or OCR a photo into structured day data.
//

import SwiftUI
import PhotosUI
import Vision

/// Single source of truth for paste-mode copy (subtitle + editor placeholder examples).
private enum ProgramPasteFormatGuide {
    /// Shown under the title in `OnboardingShell` for paste import only.
    static let subtitle =
        "Day name on its own line (Push, Pull, Legs, Upper, Lower, Full body, Arms, Chest, Back, Shoulders, Day 1 to Day 6, or a weekday). "
        + "Each exercise line: name, then setxrepxkg, or kgxrep if you omit sets. Use kg or lb, or BW for bodyweight. "
        + "Lines starting with // are skipped."

    /// Placeholder is examples only so it does not repeat the subtitle.
    static let placeholderExamples = [
        "Push",
        "Bench press 4x8x60kg",
        "Incline DB press 3x10x22kg",
        "",
        "Pull",
        "Deadlift 3x5x100kg",
        "Pull-up 4x8 BW",
        "Barbell row 4x8x60kg",
        "",
        "Legs",
        "Squat 4x6x80kg",
        "Leg press 3x10x120kg",
    ].joined(separator: "\n")
}

struct OnboardingProgramImportView: View {
    @Environment(OnboardingViewModel.self) private var vm

    var progressStep: Int
    var progressTotal: Int
    var onContinue: () -> Void

    @State private var pastedText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    @State private var parsedDays: [ImportedProgramDay] = []
    @State private var isParsing = false
    @State private var errorMessage: String?
    @State private var isPhotoPickerPresented = false

    private var isPhotoMode: Bool {
        vm.importMethod == .photo
    }

    private var canParse: Bool {
        if isPhotoMode {
            return selectedPhotoData != nil
        }
        return !pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        OnboardingShell(
            title: parsedDays.isEmpty ? inputTitle : "Check your program",
            subtitle: parsedDays.isEmpty ? helperSubtitle : "Check this before you continue. You can still edit the exercises next.",
            ctaLabel: parsedDays.isEmpty ? parseLabel : "Use program",
            ctaEnabled: parsedDays.isEmpty ? canParse && !isParsing : !parsedDays.isEmpty,
            progressStep: progressStep,
            progressTotal: progressTotal,
            onContinue: handlePrimaryAction
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                if parsedDays.isEmpty {
                    inputSection
                } else {
                    reviewSection
                }
            }
        }
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            selectedPhotoData = try? await selectedPhoto.loadTransferable(type: Data.self)
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

    private var inputTitle: String {
        switch vm.importMethod {
        case .photo:
            return "Add a photo"
        case .paste:
            return "Paste your program"
        case .manual:
            return "Add your program"
        }
    }

    private var parseLabel: String {
        isParsing ? "Reading…" : "Read program"
    }

    @ViewBuilder
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if isPhotoMode {
                let hasPhoto = selectedPhotoData != nil
                AppSecondaryButton(
                    hasPhoto ? "Replace photo" : "Choose photo",
                    icon: .photo
                ) {
                    isPhotoPickerPresented = true
                }
                .photosPicker(
                    isPresented: $isPhotoPickerPresented,
                    selection: $selectedPhoto,
                    matching: .images
                )

                if hasPhoto {
                    Text("Photo ready.")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textSecondary)
                }
            } else {
                AppTextEditor(
                    text: $pastedText,
                    placeholder: ProgramPasteFormatGuide.placeholderExamples
                )
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
            }
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

    @ViewBuilder
    private var reviewSection: some View {
        VStack(spacing: AppSpacing.sm) {
            ForEach(parsedDays) { day in
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(day.name)
                        .font(AppFont.sectionHeader.font)
                        .foregroundStyle(AppColor.textPrimary)

                    VStack(spacing: AppSpacing.xs) {
                        ForEach(day.exercises) { exercise in
                            HStack(alignment: .center, spacing: AppSpacing.sm) {
                                Text(exercise.name)
                                    .font(AppFont.body.font)
                                    .foregroundStyle(AppColor.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(
                                    WorkoutTargetFormatter.importedProgramExerciseSummary(
                                        sets: exercise.sets,
                                        reps: exercise.reps,
                                        weightKg: exercise.weightKg
                                    )
                                )
                                    .font(AppFont.caption.font)
                                    .foregroundStyle(AppColor.textSecondary)
                                    .multilineTextAlignment(.trailing)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                            }
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.sm)
                            .background(AppColor.background)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                        }
                    }
                }
                .appCardStyle()
            }
        }

        AppGhostButton("Try again") {
            parsedDays = []
        }
    }

    private var helperSubtitle: String? {
        switch vm.importMethod {
        case .photo:
            return "Use a clear photo of the full page."
        case .paste:
            return ProgramPasteFormatGuide.subtitle
        case .manual:
            return nil
        }
    }

    private func handlePrimaryAction() {
        if parsedDays.isEmpty {
            Task { await parseProgram() }
        } else {
            vm.applyImportedProgram(parsedDays)
            onContinue()
        }
    }

    @MainActor
    private func parseProgram() async {
        guard !isParsing else { return }
        isParsing = true
        defer { isParsing = false }

        let sourceText: String?
        if isPhotoMode {
            guard let selectedPhotoData else {
                errorMessage = "Choose a photo first."
                return
            }
            sourceText = await ProgramImportParser.extractText(from: selectedPhotoData)
        } else {
            sourceText = pastedText
        }

        let parsed = ProgramImportParser.parse(sourceText ?? "")
        guard !parsed.isEmpty else {
            errorMessage = "Couldn't find exercises. Try a clearer photo or put each day on its own line."
            return
        }
        parsedDays = parsed
    }
}

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
