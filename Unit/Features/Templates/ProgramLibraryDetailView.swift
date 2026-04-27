//
//  ProgramLibraryDetailView.swift
//  Unit
//
//  Detail view for a catalog program: shows description + per-day exercise
//  breakdown, and a primary button to import the program as the user's new
//  split.
//

import SwiftUI
import SwiftData

struct ProgramLibraryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appTabSelection) private var appTabSelection

    let program: ProgramTemplate

    @State private var showingConfirmation = false

    var body: some View {
        AppScreen(
            showsNativeNavigationBar: true
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                headerBlock
                daysCard
                AppPrimaryButton("Use this program") {
                    showingConfirmation = true
                }
            }
        }
        .navigationTitle(program.name)
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarChrome()
        .confirmationDialog(
            "Import \(program.name)?",
            isPresented: $showingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Import") { importProgram() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This adds the program to your list. Any missing exercises will be created automatically.")
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(program.description)
                .font(AppFont.body.font)
                .foregroundStyle(AppColor.textPrimary)
                .lineSpacing(3)
            HStack(spacing: AppSpacing.xs) {
                AppTag(text: program.level.displayName, style: .muted, layout: .compactCapsule)
                AppTag(text: program.goal.displayName, style: .muted, layout: .compactCapsule)
                AppTag(text: "\(program.daysPerWeek) days/week", style: .muted, layout: .compactCapsule)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.md)
    }

    private var daysCard: some View {
        AppCard(contentInset: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Days")
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xs)

                AppDividedList(program.days) { day in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(day.name)
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textPrimary)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.top, AppSpacing.sm)
                            .padding(.bottom, AppSpacing.xs)

                        ForEach(day.items) { item in
                            AppListRow(title: item.exerciseName, style: .display) {
                                Text(WorkoutTargetFormatter.setRepCompact(setCount: item.setCount, reps: item.repTarget) ?? "")
                                    .font(AppFont.muted.font)
                                    .foregroundStyle(AppFont.muted.color)
                                    .monospacedDigit()
                            }
                        }
                    }
                    .padding(.bottom, AppSpacing.xs)
                }
                .padding(.bottom, AppSpacing.md)
            }
        }
    }

    private func importProgram() {
        _ = ProgramImporter.importProgram(program, into: modelContext)
        dismiss()
    }
}
