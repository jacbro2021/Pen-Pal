//
//  EditorView.swift
//  Pen Pal
//
//  Created by jacob brown on 12/26/24.
//

import PDFKit
import PencilKit
import SwiftUI

struct EditorView: View {
    @Bindable var document: Document
    var closureWrapper: ClosureWrapper = .init()

    var body: some View {
        VStack {
            CanvasView(document: document, closureWrapper: closureWrapper)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    addPage()
                } label: {
                    Text("Add page")
                }
            }

            ToolbarItem(placement: .primaryAction) {
                ShareLink(
                    item: document,
                    preview: SharePreview(
                        document.title,
                        image: Image(uiImage: document.thumbnail)
                    )
                )
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .ignoresSafeArea()
    }

    private func addPage() {
        closureWrapper.closure()
    }
}

class ClosureWrapper {
    var closure: () -> Void = {}
}

#Preview {
    NavigationStack {
        EditorView(document: PreviewData.documentExamples[0])
            .modelContainer(PreviewData.getPreviewModelContainer())
    }
}
