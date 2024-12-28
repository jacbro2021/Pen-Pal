//
//  EditorView.swift
//  Pen Pal
//
//  Created by jacob brown on 12/26/24.
//

import SwiftUI
import PDFKit

struct EditorView: View {
    @Bindable var document: Document
    
    var body: some View {
        VStack {
            CanvasView(document: document)
            
            Button {
                let pdf = document.pdfDocument
                let newPage = PDFPage()
                pdf.insert(newPage, at: pdf.pageCount)
                
                document.pdfDocument = pdf
                
            } label: {
                Text("Add page")
            }
            .padding(50)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    EditorView(document: PreviewData.documentExamples[0])
        .modelContainer(PreviewData.getPreviewModelContainer())
}
