//
//  DocumentModel.swift
//  Pen Pal
//
//  Created by jacob brown on 12/20/24.
//

import Foundation
import PDFKit
import PencilKit
import SwiftData

@Model
class Document {
    @Attribute(.unique) var id: UUID
    var lastTouched: Date
    var title: String
    @Attribute(.externalStorage) private var document: Data
    @Attribute(.externalStorage) private var drawings: [Data]

    var parentID: UUID

    init(title: String, pdfDocument: PDFDocument = PDFDocument(), parentID: UUID = UUID()) {
        self.title = title
        self.lastTouched = .now
        self.id = UUID()

        guard let documentData = pdfDocument.dataRepresentation() else {
            fatalError("Failed to convert PDF document to data blob.")
        }
        self.document = documentData
        self.drawings = []
        self.parentID = parentID
    }

    var pdfDocument: PDFDocument {
        get {
            guard let pdf = PDFDocument(data: self.document) else {
                fatalError("Failed to initialize PDF document from data blob.")
            }
            return pdf
        }
        set {
            guard let data = newValue.dataRepresentation() else {
                fatalError("Failed to convert PDF document to data blob.")
            }
            self.document = data
        }
    }

    var pdfDrawings: [PKDrawingReference] {
        get {
            do {
                let references = try self.drawings.map { try PKDrawingReference(data: $0) }
                return references
            } catch {
                fatalError("Failed to initialize PDF drawings from data.")
            }
        }
        set {
            let blob = newValue.map { $0.dataRepresentation() }
            self.drawings = blob
        }
    }

    var thumbnail: UIImage {
        guard let firstPage = pdfDocument.page(at: 0) else {
            fatalError("Failed to retrieve first page from document.")
        }

        // Get the PDF page size
        let pdfPageBounds = firstPage.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pdfPageBounds.size)

        // Render the PDF page into an image, flipping it to match UIKit's coordinate system
        let pdfImage = renderer.image { context in
            let cgContext = context.cgContext

            // Flip the context vertically
            cgContext.translateBy(x: 0, y: pdfPageBounds.size.height)
            cgContext.scaleBy(x: 1, y: -1)

            // Draw the PDF page
            firstPage.draw(with: .mediaBox, to: cgContext)
        }
        
        var drawingImage: UIImage? = nil

        // Convert the first PKDrawing to an image
        if !pdfDrawings.isEmpty {
            let drawing = pdfDrawings[0]
            drawingImage = drawing.image(from: pdfPageBounds, scale: UIScreen.main.scale)
        }

        // Overlay the drawing on the flipped PDF image
        return renderer.image { context in
            pdfImage.draw(in: pdfPageBounds) // Draw the corrected PDF image
            
            if let drawingImage = drawingImage {
                drawingImage.draw(in: pdfPageBounds) // Overlay the drawing
            }
        }
    }
}
