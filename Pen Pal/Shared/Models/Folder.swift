//
//  FolderModel.swift
//  Pen Pal
//
//  Created by jacob brown on 12/20/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Folder {
    @Attribute(.unique) var id: UUID
    var lastTouched: Date
    var title: String
    var documents: [Document]
    var subFolders: [Folder]
    
    var parentID: UUID
    
    private var tagColorRed: CGFloat = 0
    private var tagColorGreen: CGFloat = 0
    private var tagColorBlue: CGFloat = 0
    

    init(title: String, documents: [Document] = [], subFolders: [Folder] = [], parentID: UUID = UUID(), tagColor: Color = .blue) {
        id = UUID()
        lastTouched = .now
        
        self.title = title
        self.documents = documents
        self.subFolders = subFolders
        self.parentID = parentID
        self.tagColor = tagColor
    }
    
    var tagColor: Color {
        get {
            Color(cgColor: CGColor(red: tagColorRed, green: tagColorGreen, blue: tagColorBlue, alpha: 1))
        }
        set {
            let uiTagColor = UIColor(newValue)
            uiTagColor.getRed(&tagColorRed, green: &tagColorGreen, blue: &tagColorBlue, alpha: nil)
        }
    }
}
