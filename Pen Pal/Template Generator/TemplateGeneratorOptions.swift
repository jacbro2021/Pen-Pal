//
//  TemplateGeneratorOptions.swift
//  Pen Pal
//
//  Created by jacob brown on 12/26/24.
//

import Foundation
import SwiftUI

class TGOptions {
    var size: TGPaperSize = .A4
    var pattern: TGPattern = .blank
    var backgroundColor: Color = .white
    var accentColor: Color = .black
    
    enum TGPaperSize: String, CaseIterable {
        case A0 = "A0"
        case A1 = "A1"
        case A2 = "A2"
        case A3 = "A3"
        case A4 = "A4 (Default)"
        case A5 = "A5"
        case A6 = "A6"
        case A7 = "A7"
        case A8 = "A8"
        case Letter = "Letter"

        var rect: CGRect {
            switch self {
            case .A0: return CGRect(x: 0, y: 0, width: 2384, height: 3370)
            case .A1: return CGRect(x: 0, y: 0, width: 1684, height: 2384)
            case .A2: return CGRect(x: 0, y: 0, width: 1191, height: 1684)
            case .A3: return CGRect(x: 0, y: 0, width: 842, height: 1191)
            case .A4: return CGRect(x: 0, y: 0, width: 595, height: 842)
            case .A5: return CGRect(x: 0, y: 0, width: 420, height: 595)
            case .A6: return CGRect(x: 0, y: 0, width: 298, height: 420)
            case .A7: return CGRect(x: 0, y: 0, width: 210, height: 298)
            case .A8: return CGRect(x: 0, y: 0, width: 148, height: 210)
            case .Letter: return CGRect(x: 0, y:0, width: 612, height: 792)
            }
        }
    }
    
    enum TGPattern: String, CaseIterable {
        case blank = "Blank"
        case grid = "Grid"
        case lined = "Lined"
        case doubleLined = "Lined (Double Spaced)"
        case dotted = "Dotted"
        case crossed = "Crossed"
    }
}

