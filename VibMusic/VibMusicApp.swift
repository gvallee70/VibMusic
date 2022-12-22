//
//  VibMusicApp.swift
//  VibMusic
//
//  Created by Gwendal on 15/12/2022.
//

import SwiftUI

@main
struct VibMusicApp: App {
    var body: some Scene {
        WindowGroup {
            //TunerView(conductor: TunerConductor())
            HomeView(model: HomeStore())
        }
    }
}
