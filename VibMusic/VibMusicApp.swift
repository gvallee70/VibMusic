//
//  VibMusicApp.swift
//  VibMusic
//
//  Created by Gwendal on 15/12/2022.
//

import SwiftUI

@main
struct VibMusicApp: App {
    @StateObject var homeStoreViewModel = HomeStore()
    @StateObject var audioKitViewModel = TunerConductor()
    @StateObject var ambiancesStoreViewModel = AmbiancesViewModel()
    @ObservedObject var iphoneSessionDelegate = iPhoneSessionDelegate()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(self.audioKitViewModel)
                .environmentObject(self.homeStoreViewModel)
                .environmentObject(self.ambiancesStoreViewModel)
                .environmentObject(self.iphoneSessionDelegate)
            
            }
    }
}
