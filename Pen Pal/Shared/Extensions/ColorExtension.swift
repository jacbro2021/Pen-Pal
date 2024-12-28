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
}
