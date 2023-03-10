//
//  RootView.swift
//  VibMusic
//
//  Created by Gwendal on 10/02/2023.
//

import SwiftUI
import HomeKit

struct RootView: View {
    @EnvironmentObject var homeStoreViewModel: HomeStoreViewModel
    @EnvironmentObject var audioKitViewModel: AudioKitViewModel
    @EnvironmentObject var ambiancesStoreViewModel: AmbiancesViewModel
    @EnvironmentObject var iphoneSessionDelegate: iPhoneSessionDelegate

    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: self.$path) {
            VStack {
                TabView {
                    HomeKitTabView()
                        .tabItem {
                            Label("HomeKit", systemImage: "homekit")
                        }

                    AmbiancesTabView()
                        .tabItem {
                            Label("Ambiances", systemImage: "lightbulb.circle.fill")
                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            .navigationTitle("Vib'Music App")
            .onAppear {
                self.iphoneSessionDelegate.sendAmbiancesToWatchApp(ambiances: self.ambiancesStoreViewModel.ambiances)
                self.iphoneSessionDelegate.sendCurrentAmbianceToWatchApp(self.ambiancesStoreViewModel.currentAmbiance)
            
                self.ambiancesStoreViewModel.homeStoreViewModel = self.homeStoreViewModel
                self.audioKitViewModel.homeStoreViewModel = self.homeStoreViewModel
                self.audioKitViewModel.start()
                
                if let currentStoredHome = self.homeStoreViewModel.currentStoredHome {
                    self.homeStoreViewModel.getAllLightbulbsServicesForAllRooms(from: currentStoredHome)
                }
            }
        }
    }
}
