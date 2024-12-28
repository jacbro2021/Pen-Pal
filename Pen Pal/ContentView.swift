//
//  ContentView.swift
//  Pen Pal
//
//  Created by jacob brown on 12/20/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext

    var body: some View {
        NavigationStack {
            DocumentExplorerView()
                .navigationTitle("Documents")
                .modelContext(modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.getPreviewModelContainer())
}
