//
//  VibMusicApp.swift
//  VibMusic
//
//  Created by Gwendal on 15/12/2022.
//

import SwiftUI

@main
struct VibMusicApp: App {
    @Environment(\.scenePhase) var scenePhase

    let audioKitViewModel = TunerConductor()
    
    var body: some Scene {
        WindowGroup {
            RootView(deviceToUse: audioKitViewModel.initialDevice, model: HomeStore(), audioKitViewModel: audioKitViewModel)
        }
//        .onChange(of: scenePhase) { newPhase in
//                        if newPhase == .active {
//                            print("Active")
//                        } else if newPhase == .inactive {
//                            print("Inactive")
//                        } else if newPhase == .background {
//                            print("Background")
//                        }
//            var conductor = TunerConductor()
//            conductor.start()
//                    }
    }
}
