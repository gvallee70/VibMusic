//
//  Ambiance.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import Foundation
import SwiftUI

class Ambiance {
    var name: String
    var lightBrightness: Int
    var lightHue: Int
    
    init(name: String, lightBrightness: Int, lightHue: Int) {
        self.name = name
        self.lightBrightness = lightBrightness
        self.lightHue = lightHue
    }
    
}
