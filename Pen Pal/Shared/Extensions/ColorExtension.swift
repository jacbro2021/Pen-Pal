//
//  ColorExtension.swift
//  Pen Pal
//
//  Created by jacob brown on 12/26/24.
//

import Foundation
import SwiftUI

extension Color {
    static func toCGColor(_ color: Color) -> CGColor {
        return UIColor(color).cgColor
    }
    
    static func fromCGColor(_ color: CGColor) -> Color {
        return Color(UIColor(cgColor: color))
    }
}

extension CGColor {
    static func getRGBAComponents(from cgColor: CGColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        guard let components = cgColor.components else { return nil }
        
        switch cgColor.numberOfComponents {
        case 4: // RGBA (most common case)
            return (components[0], components[1], components[2], components[3])
        case 2: // Grayscale + alpha
            let gray = components[0]
            let alpha = components[1]
            return (gray, gray, gray, alpha) // Treat grayscale as RGB with equal values
        default:
            return nil // Unsupported color space
        }
    }
}

