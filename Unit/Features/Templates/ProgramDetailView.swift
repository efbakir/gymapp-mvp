//
//  ProgramDetailView.swift
//  Unit
//
//  Program detail: routine day list and edit entry point.
//

import SwiftUI
import SwiftData

struct ProgramDetailView: View {
    @Bindable var split: Split

    @Query(sort: \DayTemplate.name) private var allTemplates: [DayTemplate]
    @State private var showingEdit = false

    private var orderedTemplates: [DayTemplate] {
        let byID = Dictionary(uniqueKeysWithValues: allTemplates.map { ($0.id, $0) })
        let linked = split.orderedTemplateIds.compactMap { byID[$0] }
        if !linked.isEmpty { return linked }
        return allTemplates.filter { $0.splitId == split.id }
    }

    private var displayName: String {
        let trimmed = split.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Program" : trimmed
    }

    var body: some View {
        AppScreen(showsNativeNavigationBar: true) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                routineDaysCard
            }
        }
        .navigationTitle(displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingEdit = true } label: {
                    Label("Edit program", systemImage: AppIcon.program.systemName)
                        .labelStyle(.iconOnly)
                }
                .accessibilityLabel("Edit program")
            }
        }
        .appNavigationBarChrome()
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $showingEdit) {
            EditProgramView(split: split)
        }
        .tint(AppColor.systemTint)
    }

    // MARK: - Routine Days

    private var routineDaysCard: some View {
        AppCard(contentInset: 0) {
            AppDividedList(orderedTemplates) { template in
                let index = orderedTemplates.firstIndex(where: { $0.id == template.id }) ?? 0
                NavigationLink(value: template) {
                    PreviewListRow(
                        title: template.displayName,
                        subtitle: routineSubtitle(dayIndex: index, template: template)
                    )
                    .padding(.horizontal, AppSpacing.md)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    // MARK: - Helpers

    private func routineSubtitle(dayIndex: Int, template: DayTemplate) -> String {
        let count = template.orderedExerciseIds.count
        return count == 0 ? "Add exercises" : "\(count) exercise\(count == 1 ? "" : "s")"
    }
}

#Preview {
    NavigationStack {
        let container = PreviewSampleData.makePreviewContainer()
        let split = (try? container.mainContext.fetch(FetchDescriptor<Split>()))?.first

        Group {
            if let split {
                ProgramDetailView(split: split)
                    .modelContainer(container)
            }
        }
    }
}
