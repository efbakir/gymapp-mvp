//
//  AddTemplateView.swift
//  Unit
//
//  Create a new day template inside a split.
//

import SwiftUI
import SwiftData

struct AddTemplateView: View {
    let split: Split

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            AppScreen(
                primaryButton: PrimaryButtonConfig(label: "Create Day", isEnabled: canSave, action: save),
                customHeader: ProductTopBar(
                    title: "New Day",
                    trailingActions: [
                        .text(AppCopy.Nav.close) { dismiss() }
                    ]
                ).eraseToAnyView()
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    AppSectionHeader("Day name")

                    TextField("e.g. Push", text: $name)
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textPrimary)
                        .textInputAutocapitalization(.words)
                        .appInputFieldStyle(height: 52)
                }
            }
        }
    }

    private func save() {
        let template = DayTemplate(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            splitId: split.id
        )
        modelContext.insert(template)

        var ids = split.orderedTemplateIds
        ids.append(template.id)
        split.orderedTemplateIds = ids

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let container = PreviewSampleData.makePreviewContainer()
    let split = (try? container.mainContext.fetch(FetchDescriptor<Split>()))?.first

    return Group {
        if let split {
            AddTemplateView(split: split)
                .modelContainer(container)
        }
    }
}
