//
//  FolderEditorSheet.swift
//  MarkFlow Studio
//

import SwiftUI

struct FolderEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let initialName: String
    let saveTitle: String
    let onSave: (String) -> Void

    @State private var folderName: String

    init(title: String, initialName: String = "", saveTitle: String = "Save", onSave: @escaping (String) -> Void) {
        self.title = title
        self.initialName = initialName
        self.saveTitle = saveTitle
        self.onSave = onSave
        _folderName = State(initialValue: initialName)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Folder name", text: $folderName)
                    .onSubmit(save)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveTitle, action: save)
                }
            }
        }
    }

    private func save() {
        onSave(folderName)
        dismiss()
    }
}
