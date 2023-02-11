//
//  RootView.swift
//  VibMusic
//
//  Created by Gwendal on 22/12/2022.
//

import SwiftUI
import AudioKit

struct SettingsView: View {
    @EnvironmentObject var audioKitViewModel: TunerConductor
    @EnvironmentObject var homeStoreViewModel: HomeStore
    
    @State var deviceToUse: Device
    @State var soundDetectionIsOn: Bool = UserDefaults.standard.bool(forKey: "soundDetectionIsOn")
  
    
    var body: some View {
        List {
            Section(header:
                Text("Gestion")
            ) {
                NavigationLink(destination: AmbiancesListView()) {
                    Text("Mes ambiances")
                }
                NavigationLink(destination: HomesView()) {
                    Text("Mon HomeKit")
                }
            }
            Section(header: HStack {
                Text("Paramètres de Vib'Music")
            }) {
                VStack(alignment: .leading) {
                    Text("Microphone")
                        .font(.subheadline)
                    Picker("Microphone", selection: $deviceToUse) {
                        ForEach(audioKitViewModel.getDevices(), id: \.self) {
                            Text("Micro \(String($0.deviceID.split(separator: " ")[2]))").tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: deviceToUse) { newValue in
                        audioKitViewModel.setInputDevice(to: newValue)
                    }
                }
                .padding(.vertical, 5)
            
                Toggle(isOn: $soundDetectionIsOn) {
                    Text("Utiliser la détection du son automatique")
                }
                .onAppear {
                    self.soundDetectionIsOn = UserDefaults.standard.bool(forKey: "soundDetectionIsOn")
                }
                .onChange(of: soundDetectionIsOn) { newValue in
                    UserDefaults.standard.set(soundDetectionIsOn, forKey: "soundDetectionIsOn")
                }
            }
            
            AmplitudeSection(audioKitViewModel: self.audioKitViewModel)
                .onAppear {
                    self.audioKitViewModel.homeViewModel = self.homeStoreViewModel
                    self.audioKitViewModel.start()
                }
        }
        .navigationTitle("Paramètres")
    }
}
