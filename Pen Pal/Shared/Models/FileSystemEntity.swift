//
//  PresentableItem.swift
//  Pen Pal
//
//  Created by jacob brown on 12/23/24.
//

import Foundation

enum FileSystemEntity {
    case document(document: Document)
    case folder(folder: Folder)
}

extension FileSystemEntity: Identifiable {
    var id: UUID {
        switch self {
        case .document(let document):
            document.id
        case .folder(let folder):
            folder.id
        }
    }
}

extension FileSystemEntity: Comparable {
    var lastTouched: Date {
        switch self {
        case .document(let document):
            document.lastTouched
        case .folder(let folder):
            folder.lastTouched
        }
    }
    
    static func < (lhs: FileSystemEntity, rhs: FileSystemEntity) -> Bool {
        lhs.lastTouched < rhs.lastTouched
    }
}
