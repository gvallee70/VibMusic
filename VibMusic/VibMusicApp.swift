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
    @ObservedObject var ambiancesStoreViewModel = AmbiancesViewModel()
    @ObservedObject var iphoneSessionDelegate = iPhoneSessionDelegate()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(self.audioKitViewModel)
                .environmentObject(self.homeStoreViewModel)
                .environmentObject(self.ambiancesStoreViewModel)
                .environmentObject(self.iphoneSessionDelegate)
                .onReceive(self.ambiancesStoreViewModel.$currentAmbiance) { newAmbiance in
                    self.iphoneSessionDelegate.sendCurrentAmbianceToWatchApp(newAmbiance)
                }
                .onReceive(self.iphoneSessionDelegate.$currentAmbiance) { newAmbiance in
                    if let newAmbiance = newAmbiance {
                        self.ambiancesStoreViewModel.storeCurrentAmbiance(newAmbiance)
                    }
                }
            }
    }
}
