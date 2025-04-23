//
//  DocumentNavigatorView.swift
//  Pen Pal
//
//  Created by jacob brown on 12/20/24.
//

import PDFKit
import SwiftData
import SwiftUI

struct DocumentExplorerView: View {
    @Environment(\.modelContext) var modelContext
    
    var parentID: UUID

    @Query var folders: [Folder]
    @Query var documents: [Document]
    
    @State private var showingSheet = false
    
    private var fsEntities: [FileSystemEntity] {
        let items: [FileSystemEntity] = folders.map { .folder(folder: $0) } +
            documents.map { .document(document: $0) }
        return items.sorted().reversed()
    }
    
    init(parentID: UUID = .RootID) {
        self.parentID = parentID
        
        let folderFilter: Predicate<Folder> = #Predicate { folder in
            parentID == folder.parentID
        }
        
        let documentFilter: Predicate<Document> = #Predicate { document in
            parentID == document.parentID
        }

        _folders = Query(filter: folderFilter)
        _documents = Query(filter: documentFilter)
    }
    
    var body: some View {
        List {
            if fsEntities.isEmpty {
                ContentUnavailableView("Click '+' to create folders and documents.", systemImage: "document.fill")
            } else {
                entityList
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingSheet) {
            CreateFSEntityView(parentID: parentID)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { addEntityButton }
        }
    }
    
    private var entityList: some View {
        ForEach(fsEntities) { item in
            switch item {
            case .folder(let folder):
                folderThumbnail(folder: folder)
            case .document(let document):
                documentThumbnail(document: document)
            }
        }
        .onDelete(perform: deleteItem)
    }
    
    private var addEntityButton: some View {
        Button {
            showingSheet.toggle()
        } label: {
            Image(systemName: "plus")
                .font(.title)
        }
    }
    
    private func folderThumbnail(folder: Folder) -> some View {
        NavigationLink {
            DocumentExplorerView(parentID: folder.id)
                .navigationTitle(folder.title)
        } label: {
            HStack {
                Image(systemName: "folder.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .foregroundStyle(folder.tagColor)
                    .padding()
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(folder.title)
                        .font(.title2)
                        .bold()
                        .lineLimit(1)
                    
                    Text("Folder")
                        .foregroundStyle(folder.tagColor)
                        .padding(5)
                        .font(.headline)
                        .background(folder.tagColor.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                
                Spacer()
                
                Text("Last Edited: \(formatDate(folder.lastTouched))")
                    .lineLimit(1)
                    .font(.callout)
            }
        }
    }
    
    private func documentThumbnail(document: Document) -> some View {
        NavigationLink {
            EditorView(document: document)
                .modelContext(modelContext)
        } label: {
            HStack {
                Image(uiImage: document.thumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .padding()
                    .shadow(radius: 5)
                    
                VStack(alignment: .leading, spacing: 5) {
                    Text(document.title)
                        .font(.title2)
                        .bold()
                        .lineLimit(1)
                    
                    Text("Document")
                        .foregroundStyle(document.tagColor)
                        .padding(5)
                        .font(.headline)
                        .background(document.tagColor.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                
                Spacer()
                
                Text("Last Edited: \(formatDate(document.lastTouched))")
                    .lineLimit(1)
                    .font(.callout)
            }
        }
    }
    
    private func deleteItem(indicies: IndexSet) {
        for index in indicies {
            let item = fsEntities[index]
            
            switch item {
            case .folder(let folder):
                modelContext.delete(folder)
            case .document(let document):
                modelContext.delete(document)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        
        let relativeString = formatter.localizedString(for: date, relativeTo: Date())
        
        let calendar = Calendar.current
        if calendar.isDateInYesterday(date) || calendar.isDateInWeekend(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            let timeString = timeFormatter.string(from: date)
            
            return "\(relativeString) at \(timeString)"
        } else if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            let timeString = timeFormatter.string(from: date)
            
            return "\(timeString)"
        }
        
        return relativeString
    }
}

#Preview {
    NavigationStack {
        DocumentExplorerView(parentID: UUID.RootID)
            .navigationTitle("Documents")
            .modelContainer(PreviewData.getPreviewModelContainer())
    }
}
