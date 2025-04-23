//
//  Thumbnail.swift
//  Pen Pal
//
//  Created by jacob brown on 12/29/24.
//

import Foundation
import SwiftUI
import PDFKit
import PencilKit

struct Thumbnail: Identifiable {
    var id = UUID()
    let index: Int
    let page: PDFPage
    let drawingReference: PKDrawingReference
    var image: UIImage
}
