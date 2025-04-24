////
////  CodablePDFDocument.swift
////  Pen Pal
////
////  Created by jacob brown on 1/2/25.
////
//
//import Foundation
//import PDFKit
//
//class CodablePDFDocument {
//    private var pdfData: Data
//    private var cachedPDFDocument: PDFDocument?
//    
//    var pdfDocument: PDFDocument {
//        if let cached = cachedPDFDocument {
//            return cached
//        }
//        if let newDocument = PDFDocument(data: pdfData) {
//            cachedPDFDocument = newDocument
//            return newDocument
//        }
//        fatalError("Error in getter of pdfDocument of CodablePDfDocument")
//    }
//    
//    init(pdfDocument: PDFDocument) {
//        self.pdfData = pdfDocument.dataRepresentation() ?? Data()
//        self.cachedPDFDocument = pdfDocument
//    }
//    
//    convenience init() {
//        let pdf = PDFDocument()
//        self.init(pdfDocument: pdf)
//    }
//    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        self.pdfData = try container.decode(Data.self)
//        self.cachedPDFDocument = nil
//    }
//    
//    static func == (lhs: CodablePDFDocument, rhs: CodablePDFDocument) -> Bool {
//        lhs.pdfData == rhs.pdfData
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(pdfData)
//    }
//}
//
