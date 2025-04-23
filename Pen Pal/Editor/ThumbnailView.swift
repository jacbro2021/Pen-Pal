//
//  ThumbnailView.swift
//  Pen Pal
//
//  Created by jacob brown on 12/29/24.
//

import Foundation
import PDFKit
import PencilKit
import SwiftUI

struct ThumbnailView: View {
    @Binding var pdfView: PDFView
    var document: Document
    var maxPageWidth: CGFloat
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(document.thumbnails) { thumbnail in
                    pageThumbnail(thumbnail)
                }
            }
        }
        .background(Color.init(uiColor: .systemGray6))
    }
    
    private func pageThumbnail(_ thumbnail: Thumbnail) -> some View {
        Button {
            pdfView.go(to: thumbnail.page)
        } label: {
                VStack {
                    Image(uiImage: thumbnail.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: maxPageWidth)
                        .padding([.horizontal, .top])
                    Text("\(thumbnail.index+1)")
                        .padding(.bottom)
                }
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    ThumbnailView(pdfView: .constant(PDFView()),
                  document: PreviewData.testDocument,
                  maxPageWidth: 100)
}
