//
//  RootView.swift
//  VibMusic
//
//  Created by Gwendal on 10/02/2023.
//

import SwiftUI
import WatchConnectivity

struct RootView: View {
    @EnvironmentObject var homeStoreViewModel: HomeStore
    @EnvironmentObject var audioKitViewModel: TunerConductor
    @EnvironmentObject var ambiancesStoreViewModel: AmbiancesViewModel
    @EnvironmentObject var iphoneSessionDelegate: iPhoneSessionDelegate

    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: self.$path) {
            VStack {
                Text("Hello world")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            .navigationTitle("Vib'Music")
            .onAppear {
                self.iphoneSessionDelegate.sendAmbiancesToWatchApp(ambiances: self.ambiancesStoreViewModel.ambiances)
                self.iphoneSessionDelegate.sendCurrentAmbianceToWatchApp(self.ambiancesStoreViewModel.currentAmbiance)
            }
            .onChange(of: self.iphoneSessionDelegate.currentAmbiance) { newCurrentAmbiance in
                self.ambiancesStoreViewModel.storeCurrentAmbiance(newCurrentAmbiance!)
            }
        }
    }
}
