//
//  PreviewData.swift
//  Pen Pal
//
//  Created by jacob brown on 12/21/24.
//

import Foundation
import SwiftData
import PDFKit

@MainActor
class PreviewData {
    static func getPreviewModelContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Document.self, Folder.self, configurations: config)
        
        for folder in folderExamples {
            container.mainContext.insert(folder)
        }
        
        for folder in subFolderExamples {
            container.mainContext.insert(folder)
        }

        for document in documentExamples {
            container.mainContext.insert(document)
        }
       
        // Test pdf document
        guard let url = Bundle.main.url(forResource: "test", withExtension: "pdf"),
              let pdfDocument = PDFDocument(url: url)
        else {
            fatalError("failed to fetch test pdf")
        }
        let testDocument = Document(title: "Test Document", pdfDocument: pdfDocument, parentID: .RootID)
        container.mainContext.insert(testDocument)
        
        return container
    }
    
    static var folderExamples: [Folder] = [
        Folder(title: "COMP 530", parentID: UUID.RootID),
        Folder(title: "COMP 211", parentID: UUID.RootID)
    ]
    
    static var subFolderExamples: [Folder] = [
        Folder(title: "Midterm 1 Study Guides", parentID: folderExamples[0].id),
        Folder(title: "Midterm 1 Study Guides", parentID: folderExamples[1].id)
    ]
    
    static var documentExamples: [Document] = [
        Document(title: "Christmas Wish-List", parentID: UUID.RootID)
    ]
}
