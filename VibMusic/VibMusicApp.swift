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

    var body: some Scene {
        WindowGroup {
            RootView(model: HomeStore())
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
