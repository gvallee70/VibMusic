//
//  VibMusicApp.swift
//  VibMusic
//
//  Created by Gwendal on 15/12/2022.
//

import SwiftUI

@main
struct VibMusicApp: App {
    @ObservedObject var homeStoreViewModel = HomeStore()
    @ObservedObject var audioKitViewModel = TunerConductor()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(self.audioKitViewModel)
                .environmentObject(self.homeStoreViewModel)
        }
    }
}
