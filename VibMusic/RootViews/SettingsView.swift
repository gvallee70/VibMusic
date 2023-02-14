//
//  RootView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import AudioKit

struct SettingsView: View {
    @EnvironmentObject var audioKitViewModel: AudioKitViewModel
    @EnvironmentObject var homeStoreViewModel: HomeStoreViewModel
    
    @State var soundDetectionIsOn: Bool = UserDefaults.standard.bool(forKey: "soundDetectionIsOn")
    
    var body: some View {
        List {
            Section(header:
                Text("Gestion")
            ) {
                NavigationLink(destination: AmbiancesListScreen()) {
                    Text("Mes ambiances")
                }
                NavigationLink(destination: HomesListScreen()) {
                    Text("Mon HomeKit")
                }
            }
                    
            Toggle(isOn: $soundDetectionIsOn) {
                Text("Utiliser la détection du son automatique")
            }
            .onAppear {
                self.soundDetectionIsOn = UserDefaults.standard.bool(forKey: "soundDetectionIsOn")
            }
            .onChange(of: soundDetectionIsOn) { newValue in
                UserDefaults.standard.set(soundDetectionIsOn, forKey: "soundDetectionIsOn")
            }
            
            AmplitudeSectionView(audioKitViewModel: self.audioKitViewModel)
        }
        .navigationTitle("Paramètres")
    }
}
