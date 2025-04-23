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

//@Model
//class Document {
//    @Attribute(.unique) var id: UUID
//    var parentID: UUID
//    var lastTouched: Date
//    var title: String
//   
//    @Attribute(.externalStorage) var document: CodablePDFDocument
//    @Attribute(.externalStorage) private var drawings: [Data]
//    @Attribute(.externalStorage) private var newPageTemplateData: Data
//
//
//    init(
//        title: String,
//        pdfDocument: CodablePDFDocument = .init(),
//        parentID: UUID = UUID(),
//        newPageTemplate: PDFDocument = PDFTemplateGenerator.createPDFTemplateInMemory()
//    ) {
//        self.id = UUID()
//        self.parentID = parentID
//        self.lastTouched = .now
//        self.title = title
//
//        self.document = pdfDocument
//        
//        guard let templateData = newPageTemplate.dataRepresentation() else {
//            fatalError("Failed to convert PDF template to data blob.")
//        }
//        self.newPageTemplateData = templateData
//
//        self.drawings = []
//        (0 ..< pdfDocument.pdfDocument.pageCount).forEach { _ in
//            self.drawings.append(PKDrawingReference().dataRepresentation())
//        }
//    }
//}
//
//extension Document {
//    var pdfDrawings: [PKDrawingReference] {
//        get {
//            do {
//                let references = try self.drawings.map { try PKDrawingReference(data: $0) }
//                return references
//            } catch {
//                fatalError("Failed to initialize PDF drawings from data.")
//            }
//        }
//        set {
//            self.drawings = newValue.map { $0.dataRepresentation() }
//        }
//    }
//    
//    var newPageTemplate: PDFDocument {
//        get {
//            guard let pdf = PDFDocument(data: self.newPageTemplateData) else {
//                fatalError("Failed to initialize PDF template from data blob.")
//            }
//            return pdf
//        }
//        set {
//            guard let data = newValue.dataRepresentation() else {
//                fatalError("Failed to convert PDF document to data blob.")
//            }
//            self.newPageTemplateData = data
//        }
//    }
//}
//

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
import SwiftUI

@Model
class Document {
    @Attribute(.unique) var id: UUID
    var lastTouched: Date
    var title: String
    @Attribute(.externalStorage) private var document: Data
    @Attribute(.externalStorage) private var drawings: [Data]
    @Attribute(.externalStorage) private var newPageTemplateData: Data

    var parentID: UUID
    
    private var red: CGFloat = 0
    private var green: CGFloat = 0
    private var blue: CGFloat = 0

    init(title: String,
         pdfDocument: PDFDocument = PDFDocument(),
         parentID: UUID = UUID(),
         newPageTemplate: PDFDocument = PDFTemplateGenerator.createPDFTemplateInMemory(),
         tagColor: Color = .orange
) {
        self.title = title
        self.lastTouched = .now
        self.id = UUID()

        guard let documentData = pdfDocument.dataRepresentation() else {
            fatalError("Failed to convert PDF document to data blob.")
        }
        self.document = documentData
        self.drawings = []
        self.parentID = parentID
        
        guard let templateData = newPageTemplate.dataRepresentation() else {
            fatalError("Failed to convert PDF template to data blob.")
        }
        self.newPageTemplateData = templateData
        self.tagColor = tagColor
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
    
    var newPageTemplate: PDFDocument {
        get {
            guard let pdf = PDFDocument(data: self.newPageTemplateData) else {
                fatalError("Failed to initialize PDF template from data blob.")
            }
            return pdf
        }
        set {
            guard let data = newValue.dataRepresentation() else {
                fatalError("Failed to convert PDF document to data blob.")
            }
            self.newPageTemplateData = data
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
    
    var tagColor: Color {
        get {
            Color(cgColor: CGColor(red: red, green: green, blue: blue, alpha: 1))
        }
        set {
            let uiTagColor = UIColor(newValue)
            uiTagColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        }
    }
}

/// Create a thumbnail UI image for each page that can be used as a thumbnail in the document explorer, and for the thumbnail view
/// within the editor.
///
/// TODO: This is pretty inefficient... Fix it.
extension Document {
    var thumbnails: [Thumbnail] {
        let tuples = self.pdfDrawings.enumerated().map { index, drawing in
            (index, drawing, self.pdfDocument.page(at: index))
        }

        var MatchedThumbnails: [Thumbnail] = []

        for (index, drawing, page) in tuples {
            guard let page = page else {
                return MatchedThumbnails
            }

            let pdfPageBounds = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pdfPageBounds.size)

            let pdfImage = renderer.image { context in
                let cgContext = context.cgContext

                cgContext.translateBy(x: 0, y: pdfPageBounds.size.height)
                cgContext.scaleBy(x: 1, y: -1)

                page.draw(with: .mediaBox, to: cgContext)
            }

            let drawingImage = drawing.image(from: pdfPageBounds, scale: UIScreen.main.scale)

            let image = renderer.image { _ in
                pdfImage.draw(in: pdfPageBounds)
                drawingImage.draw(in: pdfPageBounds)
            }

            let thumbnail = Thumbnail(index: index, page: page, drawingReference: drawing, image: image)
            MatchedThumbnails.append(thumbnail)
        }

        return MatchedThumbnails
    }
}
