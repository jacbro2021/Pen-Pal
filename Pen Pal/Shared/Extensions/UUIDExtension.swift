//
//  UUIDExtension.swift
//  Pen Pal
//
//  Created by jacob brown on 12/21/24.
//
import Foundation

extension UUID {
    static func isRootID(id: UUID) -> Bool {
        guard let rootID = UUID(uuidString: "00000000-0000-0000-0000-000000000000") else {
            fatalError("Failed to create root UUID")
        }
        
        return id == rootID
    }
    
    static var RootID: UUID {
        guard let rootID = UUID(uuidString: "00000000-0000-0000-0000-000000000000") else {
            fatalError("Failed to create root UUID")
        }
        return rootID
    }
}
