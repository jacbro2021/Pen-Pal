//
//  AddPresentableItemView.swift
//  Pen Pal
//
//  Created by jacob brown on 12/23/24.
//

import PDFKit
import SwiftData
import SwiftUI

struct CreateFSEntityView: View {
    var parentID: UUID
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
   
    // Generic detail properties.
    @State private var entityType: CreatableEntity = .folder
    @State private var entityName: String = ""
    @State private var tagColor: Color = .blue
    
    // Document detail properties.
    @State private var documentSize: TGOptions.TGPaperSize = .A4
    @State private var documentPattern: TGOptions.TGPattern = .blank
    @State private var documentBackgroundColor: Color = .white
    @State private var documentAccentColor: Color = .black
    
    var body: some View {
        Form {
            Section(header: formHeader) {}
            
            genericDetailsSection
            
            if entityType == .document {
                documentDetailsSection
            }
        }
    }
    
    private var formHeader: some View {
        VStack {
            HStack {
                Text("Create ")
                    .font(.largeTitle)
                    .bold()
                
                Text(entityType.rawValue)
                    .font(.largeTitle)
                    .bold()
                    .padding(5)
                    .foregroundStyle(tagColor)
                    .animation(.easeInOut, value: tagColor)
                    .background(tagColor.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                Spacer()
                    
                Button {
                    createNewItem()
                } label: {
                    Text("Save")
                        .font(.title3)
                        .disabled(entityName.isEmpty)
                }
            }
            .padding()
                
            if entityType == .folder {
                folderThumbnail
                    .transition(.scale.combined(with: .blurReplace))
            } else {
                documentThumbnail
                    .transition(.scale.combined(with: .blurReplace))
            }
        }
        .animation(.bouncy, value: entityType)
    }
    
    private var folderThumbnail: some View {
        Image(systemName: "folder.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100)
            .foregroundStyle(tagColor)
    }
    
    private var documentThumbnail: some View {
        let options = getTGOptions()
        let pdf = PDFTemplateGenerator.createPDFTemplateInMemory(options)
        let model = Document(title: entityName, pdfDocument: pdf)
        
        return VStack {
            Image(uiImage: model.thumbnail)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .foregroundStyle(tagColor)
        }
    }
    
    private var genericDetailsSection: some View {
        Section("Generic Details") {
            Picker("File type to create", selection: $entityType.animation()) {
                Text(CreatableEntity.folder.rawValue).tag(CreatableEntity.folder)
                Text(CreatableEntity.document.rawValue).tag(CreatableEntity.document)
            }
            .pickerStyle(.segmented)

            TextField("Name", text: $entityName)
            ColorPicker("Tag Color", selection: $tagColor.animation())
        }
    }
    
    private var documentDetailsSection: some View {
        Section("Document Details") {
            Picker("Size", selection: $documentSize) {
                ForEach(TGOptions.TGPaperSize.allCases, id: \.self) { size in
                    Text(size.rawValue)
                }
            }
            
            Picker("Pattern", selection: $documentPattern) {
                ForEach(TGOptions.TGPattern.allCases, id: \.self) { pattern in
                    Text(pattern.rawValue)
                }
            }
            
            ColorPicker("Background Color", selection: $documentBackgroundColor)
            ColorPicker("Accent Color", selection: $documentAccentColor)
        }
        .animation(.easeInOut, value: entityType)
    }
    
    private func createNewItem() {
        if entityType == .folder {
            let folder = Folder(title: entityName, parentID: parentID, tagColor: tagColor)
            modelContext.insert(folder)
        } else {
            let options = getTGOptions()
            let pdf = PDFTemplateGenerator.createPDFTemplateInMemory(options)
            let model = Document(title: entityName, pdfDocument: pdf, parentID: parentID)
            
            modelContext.insert(model)
        }
        
        dismiss()
    }
    
    private func getTGOptions() -> TGOptions {
        let options = TGOptions()
        options.size = documentSize
        options.pattern = documentPattern
        options.backgroundColor = documentBackgroundColor
        options.accentColor = documentAccentColor
        
        return options
    }
    
    enum CreatableEntity: String {
        case document = "Document"
        case folder = "Folder"
    }
}

#Preview {
    CreateFSEntityView(parentID: .RootID)
}
