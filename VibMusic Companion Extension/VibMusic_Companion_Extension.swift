//
//  VibMusic_Companion_Extension.swift
//  VibMusic Companion Extension
//
//  Created by Gwendal on 12/02/2023.
//

import AppIntents

struct VibMusic_Companion_Extension: AppIntent {
    static var title: LocalizedStringResource = "VibMusic Companion Extension"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
