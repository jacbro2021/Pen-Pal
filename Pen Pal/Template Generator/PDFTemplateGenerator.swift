//
//  PDFTemplateGenerator.swift
//  Pen Pal
//
//  Created by jacob brown on 12/26/24.
//

import CoreGraphics
import Foundation
import PDFKit
import SwiftUI

// TODO: Improve error handling in this file.

class PDFTemplateGenerator {
    static let spacing: CGFloat = 30
    
    static func createPDFTemplateInMemory(_ options: TGOptions = TGOptions()) -> PDFDocument {
        let pdfData = NSMutableData()
        guard let pdfConsumer = CGDataConsumer(data: pdfData) else {
            fatalError("Failed to create PDF consumer.")
        }
        
        var pageRect = options.size.rect
        guard let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &pageRect, nil) else {
            fatalError("Failed to create PDF context.")
        }
        let backgroundColorCG = Color.toCGColor(options.backgroundColor)
        let accentColorCG = Color.toCGColor(options.accentColor)
        
        pdfContext.beginPDFPage(nil)
        
        pdfContext.setFillColor(backgroundColorCG)
        pdfContext.fill(pageRect)
       
        switch options.pattern {
        case .blank:
            break
        case .grid:
            gridPattern(pdfContext: pdfContext, pageRect: pageRect, accentColor: accentColorCG)
        case .lined:
            linedPattern(pdfContext: pdfContext, pageRect: pageRect, accentColor: accentColorCG)
        case .doubleLined:
            doubleLinedPattern(pdfContext: pdfContext, pageRect: pageRect, accentColor: accentColorCG)
        case .dotted:
            dottedPattern(pdfContext: pdfContext, pageRect: pageRect, accentColor: accentColorCG)
        case .crossed:
            crossedPattern(pdfContext: pdfContext, pageRect: pageRect, accentColor: accentColorCG)
        }
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        if let pdfDocument = PDFDocument(data: pdfData as Data) {
            return pdfDocument
        } else {
            fatalError("Failed to create PDFDocument from data")
        }
    }
    
    private static func gridPattern(pdfContext: CGContext, pageRect: CGRect, accentColor: CGColor) {
        let gridSize: CGFloat = pageRect.width / spacing
        pdfContext.setStrokeColor(accentColor)
        pdfContext.setLineWidth(0.5)
        
        // Vertical grid lines.
        for x in stride(from: gridSize, to: pageRect.width, by: gridSize) {
            pdfContext.move(to: CGPoint(x: x, y: 0))
            pdfContext.addLine(to: CGPoint(x: x, y: pageRect.height))
        }
        
        // Horizontal grid lines.
        for y in stride(from: gridSize / 2, to: pageRect.height, by: gridSize) {
            pdfContext.move(to: CGPoint(x: 0, y: y))
            pdfContext.addLine(to: CGPoint(x: pageRect.width, y: y))
        }
        
        pdfContext.strokePath()
    }
    
    private static func linedPattern(pdfContext: CGContext, pageRect: CGRect, accentColor: CGColor) {
        let gridSize: CGFloat = pageRect.width / spacing
        pdfContext.setStrokeColor(accentColor)
        pdfContext.setLineWidth(0.5)
        
        // Horizontal grid lines.
        for y in stride(from: gridSize / 2, to: pageRect.height, by: gridSize) {
            pdfContext.move(to: CGPoint(x: spacing, y: y))
            pdfContext.addLine(to: CGPoint(x: pageRect.width-spacing, y: y))
        }
        
        pdfContext.strokePath()
    }
    
    private static func doubleLinedPattern(pdfContext: CGContext, pageRect: CGRect, accentColor: CGColor) {
        let gridSize: CGFloat = pageRect.width / spacing
        pdfContext.setStrokeColor(accentColor)
        pdfContext.setLineWidth(0.5)
        
        // Horizontal grid lines.
        for y in stride(from: gridSize / 2, to: pageRect.height, by: gridSize) {
            pdfContext.move(to: CGPoint(x: spacing, y: y*2))
            pdfContext.addLine(to: CGPoint(x: pageRect.width-spacing, y: y*2))
        }
        
        pdfContext.strokePath()
    }
    
    private static func dottedPattern(pdfContext: CGContext, pageRect: CGRect, accentColor: CGColor) {
        let gridSize: CGFloat = pageRect.width / spacing
        
        // Horizontal grid lines.
        for y in stride(from: gridSize / 2, to: pageRect.height, by: gridSize) {
            for x in stride(from: gridSize / 2, to: pageRect.width, by: gridSize) {
                let circleRect = CGRect(x: x, y: y, width: 2, height: 2)
                let path = CGMutablePath()
                path.addEllipse(in: circleRect)
                pdfContext.addPath(path)
                pdfContext.setFillColor(accentColor)
                pdfContext.fillPath()
            }
        }
        
        pdfContext.strokePath()
    }
    
    private static func crossedPattern(pdfContext: CGContext, pageRect: CGRect, accentColor: CGColor) {
        let gridSize: CGFloat = pageRect.width / spacing
        let crossDiameter: CGFloat = 10
        pdfContext.setStrokeColor(accentColor)
        pdfContext.setLineWidth(0.5)
        
        for y in stride(from: gridSize / 2, to: pageRect.height, by: gridSize) {
            for x in stride(from: gridSize / 2, to: pageRect.width, by: gridSize) {
                // Horizontal cross line.
                pdfContext.move(to: CGPoint(x: x, y: y + (crossDiameter / 2)))
                pdfContext.addLine(to: CGPoint(x: x + crossDiameter, y: y + (crossDiameter / 2)))
                
                // Vertical cross line.
                pdfContext.move(to: CGPoint(x: x + (crossDiameter / 2), y: y))
                pdfContext.addLine(to: CGPoint(x: x + (crossDiameter / 2), y: y + crossDiameter))
            }
        }
        
        pdfContext.strokePath()
    }
}
