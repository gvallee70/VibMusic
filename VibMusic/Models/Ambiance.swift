//
//  Ambiance.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI

class Ambiance: Codable, Equatable {
    static func == (lhs: Ambiance, rhs: Ambiance) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    var name: String
    var lightHue: Int
    var lightSaturation: Int
    var lightBrightness: Int
    
    init(name: String, lightHue: Int, lightSaturation: Int, lightBrightness: Int) {
        self.name = name
        self.lightHue = lightHue
        self.lightSaturation = lightSaturation
        self.lightBrightness = lightBrightness
    }
    
}
