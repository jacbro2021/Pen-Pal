//
//  Pen_PalApp.swift
//  Pen Pal
//
//  Created by jacob brown on 12/20/24.
//

import SwiftUI
import SwiftData

@main
struct Pen_PalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Folder.self, Document.self])
    }
}
