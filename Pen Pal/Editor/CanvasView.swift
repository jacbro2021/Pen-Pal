//
//  DocumentViewControllerRepresentable.swift
//  Pen Pal
//
//  Created by jacob brown on 9/14/24.
//

import PDFKit
import PencilKit
import SwiftData
import SwiftUI

struct CanvasView: UIViewControllerRepresentable {
    var document: Document
    @Environment(\.modelContext) var modelContext

    func makeUIViewController(context: Context) -> some UIViewController {
        return DocumentViewController(modelContext: modelContext, document: document)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Don't need this yet.
    }
}

class DocumentViewController: UIViewController,
    PDFPageOverlayViewProvider,
    PDFDocumentDelegate,
    PKCanvasViewDelegate
{
    private var document: Document
    private var pdfView: PDFView
    private var modelContext: ModelContext
    
    private var pageToViewMapping: [PDFPage: PKCanvasView] = [:]
    private var toolPicker: PKToolPicker
    
    private var dirty = false
    
    init(modelContext: ModelContext, document: Document) {
        self.document = document
        self.modelContext = modelContext
        self.pdfView = PDFView()
        self.toolPicker = PKToolPicker()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        pdfView = PDFView(frame: view.bounds)
        
        pdfView.pageOverlayViewProvider = self
        pdfView.displayMode = .singlePageContinuous
        pdfView.isInMarkupMode = true
        pdfView.usePageViewController(false)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        pdfView.document = document.pdfDocument
        
        pdfView.displayDirection = .vertical
        pdfView.autoScales = true
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.maxScaleFactor = 4
        
        pdfView.becomeFirstResponder()
        
        toolPicker.setVisible(true, forFirstResponder: pdfView)
        
        pdfView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(pdfView)
    }
    
    func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
        var resultView: PKCanvasView
        
        if let overlayView = pageToViewMapping[page] {
            resultView = overlayView
            toolPicker.addObserver(resultView)
        } else {
            guard let index = view.document?.index(for: page) else { return nil }
            let drawingReference: PKDrawingReference
            
            if index < document.pdfDrawings.count {
                drawingReference = document.pdfDrawings[index]
            } else {
                drawingReference = PKDrawingReference()
                document.pdfDrawings.append(drawingReference)
            }
            
            guard let drawing = try? PKDrawing(data: drawingReference.dataRepresentation()) else { return nil }
            
            resultView = PKCanvasView()
            resultView.drawing = drawing
            resultView.backgroundColor = .clear
            resultView.delegate = self
            pageToViewMapping[page] = resultView
            toolPicker.addObserver(resultView)
            
//#if targetEnvironment(simulator)
//            resultView.drawingPolicy = .anyInput
//#endif
        }
        
        return resultView
    }
    
    func pdfView(_ pdfView: PDFView, willEndDisplayingOverlayView overlayView: UIView, for page: PDFPage) {
        guard let canvas = overlayView as? PKCanvasView else { return }
        savePageDrawing(page: page, canvas: canvas)
        toolPicker.removeObserver(canvas)
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        document.lastTouched = .now
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for (page, canvas) in pageToViewMapping {
            savePageDrawing(page: page, canvas: canvas)
        }
        
        super.viewWillDisappear(animated)
    }
    
    private func savePageDrawing(page: PDFPage, canvas: PKCanvasView) {
        guard let index = pdfView.document?.index(for: page) else { return }
        
        let drawingReference = try? PKDrawingReference(data: canvas.drawing.dataRepresentation())
        guard let drawingReference = drawingReference else { return }
        
        document.pdfDrawings[index] = drawingReference
    }
}

#Preview {
    CanvasView(document: PreviewData.documentExamples[0])
        .modelContainer(PreviewData.getPreviewModelContainer())
}
